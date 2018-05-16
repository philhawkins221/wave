//
//  QueueManager.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

struct QueueManager {
    
    //MARK: - properties
    
    private let user: User
    let controller: QueueViewController
    var delegate: QueueDelegate?
    
    //MARK: - initializers
    
    init?(to controller: QueueViewController) {
        guard var found = CliqueAPI.find(user: controller.user) else { return nil }
        if !(found.me() || found.queue.listeners.contains(Identity.me)) {
            if let me = CliqueAPI.find(user: Identity.me) { found = me }
            else { return nil }
        }
        
        self.user = found
        self.controller = controller
        
        switch controller.mode {
        case .queue: delegate = QueueDelegate(to: self)
        case .history: delegate = HistoryDelegate(to: self)
        case .listeners: delegate = ListenersDelegate(to: self)
        case .requests: delegate = RequestsDelegate(to: self)
        case .radio: delegate = RadioDelegate(to: self)
        }
        
        controller.profilebar?.manage(profile: user)
        
        if user.me(), Settings.radio, controller.radio == nil { update(radio: ()) }
    }
    
    //MARK: - tasks
    
    func add(single: Single) {
        guard let single = iTunesAPI.match(single) else { return }
        add(song: single)
    }

    func add(song: Song) {
        var song = song
        if song.sender == "" { song.sender = Identity.me }
        return user.queue.requestsonly && !user.me() ?
            CliqueAPI.request(song: song, to: user.id) :
            CliqueAPI.add(song: song, to: user.id)
    }
    
    func advance() {
        Media.stop()
        if let next = CliqueAPI.advance(queue: user.id) { play(song: next) }
        else {
            stop()
            play()
        }
        
    }
    
    func client() -> User {
        var client = user
        if client.queue.voting { client.queue.queue.sort(by: { $0.votes > $1.votes }) }
        
        return client
    }
    
    func delete(requests: Void, confirmed: Bool = false) {
        guard confirmed else { return Alerts.delete(requests: (), on: controller) }
        
        update(requests: [], refresh: true)
    }
    
    func delete(queue: Void, confirmed: Bool = false) {
        guard confirmed else { return Alerts.delete(queue: (), on: controller) }
        
        var replacement = user.queue
        replacement.queue.removeAll()
        
        update(queue: replacement)
    }
    
    func find(song: Song, from controller: BrowseViewController, confirmed: Bool) {
        guard confirmed else { return Alerts.queue(song: song, on: controller) }
        
        add(song: song)
        Media.find()
        self.controller.navigationController?.popToViewController(self.controller, animated: true)
    }
    
    func invite(friend: User, confirmed: Bool = false) {
        guard user.me() else { return }
        guard confirmed else { return Alerts.invite(friend: friend, on: controller) }
        
        gm?.request(user: friend.id)
    }
    
    func manage(user: User) {
        guard let user = CliqueAPI.find(user: user.id) else { return }
        guard user.me() || user.queue.listeners.contains(Identity.me) else {
            if let me = CliqueAPI.find(user: Identity.me) { manage(user: me) }
            return
        }
        
        controller.user = user.id
        refresh()
    }
    
    func pause() {
        if Media.playing { Media.pause() }
        if Spotify.playing { Spotify.pause() }
    }

    func play() {
        guard let user = CliqueAPI.find(user: user.id) else { return }
        
        if !user.me(), let current = user.queue.current {
            if !Settings.applemusic { Alerts.inform(.noStreaming, about: user) }
            else if current.library == Catalogues.AppleMusic.rawValue { play(song: current, streaming: true) }
            else if let match = iTunesAPI.match(current) { play(song: match, streaming: true) }
        } else if Media.playing && player.playbackState == .paused {
            Media.play()
        } else if Spotify.playing && Spotify.player?.isPlaying ?? false {
            Spotify.play()
        } else if !user.queue.queue.isEmpty {
            advance()
        } else if Settings.takerequests && !user.queue.requests.isEmpty {
            var replacement = user.queue.requests
            play(song: replacement.first!)
            replacement.remove(at: 0)
            update(requests: replacement)
        } else if Settings.shuffle && controller.shuffled?.songs.first != nil {
            play(song: controller.shuffled!.songs.first!)
            controller.shuffled?.songs.remove(at: 0)
        } else if !Settings.shuffle && controller.fill?.songs.first != nil {
            play(song: controller.fill!.songs.first!)
            controller.fill?.songs.remove(at: 0)
            refresh()
        } else if Settings.radio && !q.radio.isEmpty {
            play(radio: ())
        } else if !user.library.isEmpty {
            var random = user.library.shuffled()
            if Settings.shuffle { random[0].songs.shuffle() }
            play(playlist: random.first!, at: 0)
        } else {
            stop()
        }
    }
    
    func play(playlist: Playlist, at index: Int) {
        guard index < playlist.songs.count else { return }
        var playlist = playlist
        let next = playlist.songs[index]
        playlist.songs.remove(at: index)
        
        controller.shuffled = playlist
        controller.shuffled?.songs.shuffle()
        
        playlist.songs.removeSubrange(0..<index)
        controller.fill = playlist
        
        play(song: next)
        refresh()
    }
    
    func play(radio: Void) {
        guard let next = controller.radio.first else { return }
        guard let single = iTunesAPI.match(next) else {
            controller.radio.remove(at: 0)
            play(radio: ())
            return
        }
        
        controller.radio.remove(at: 0)
        play(song: single, radio: true)
    }
    
    func play(single: Single) {
        guard let single = iTunesAPI.match(single) else { return } //TODO: inform
        play(song: single, radio: true)
    }
    
    func play(song: Song, streaming: Bool = false, radio: Bool = false) {
        guard user.me() || streaming else {
            gm?.stop(listening: ())
            play(song: song)
            return
        }
        CliqueAPI.play(song: song, for: user.id)
        
        Media.stop()
        Spotify.stop()
        
        switch song.library {
        case Catalogues.Library.rawValue:
            Media.play(song: song)
        case Catalogues.AppleMusic.rawValue:
            guard user.applemusic else { return } //TODO: inform
            Media.play(song: song)
        case Catalogues.Radio.rawValue:
            guard let song = iTunesAPI.match(song) else { return }
            play(song: song)
        default: return
        }
        
        if Settings.radio && !radio { update(radio: ()) }
        
        refresh()
        gm?.refresh()
    }
    
    func refresh() {
        controller.refresh()
    }
    
    func retreat() {
        //TODO: retreat
        if Media.playing {
            player.currentPlaybackTime = 0
        } else if Spotify.playing {
            Spotify.player?.seek(toOffset: 0) { _ in }
        }
    }
    
    func search(on controller: UIViewController) {
        guard let controller = controller as? BrowseViewController else { return }
        let streaming = user.applemusic || user.spotify
        
        controller.adding = true
        controller.final = false
        controller.navigationItem.prompt = !user.me() && user.queue.requestsonly ? "requesting song" : "adding song to queue"
        controller.user = streaming ? Identity.me : user.id
        controller.mode = streaming ? .friends : .library
    }
    
    func stop() {
        np.waves.isHidden = false
        
        if user.me() {
            //controller.fill = nil
            //controller.shuffled = nil
            CliqueAPI.stop(user: user.id)
        }
        Media.stop()
        Spotify.stop()
        
        refresh()
    }
    
    func update(listeners replacement: [String], refresh: Bool = true) {
        CliqueAPI.update(listeners: replacement, for: user.id)
        if refresh { self.refresh() }
    }
    
    func update(queue replacement: Queue, refresh: Bool = true) {
        CliqueAPI.update(queue: replacement)
        if refresh { self.refresh() }
    }
    
    func update(radio: Void) {
        DispatchQueue.global(qos: .background).async {
            let count = self.user.queue.history.count < 5 ? self.user.queue.history.count : 5
            let seeds = Array(self.user.queue.history.reversed().prefix(count))
            
            self.controller.radio = GracenoteAPI.recommend(from: seeds)
        }
    }
    
    func update(requests replacement: [Song], refresh: Bool = false) {
        CliqueAPI.update(songRequests: replacement, for: user.id)
        if refresh { self.refresh() }
    }
    
    func update(voting status: Bool, refresh: Bool = true) {
        CliqueAPI.update(voting: user.id, to: status)
        if refresh { self.refresh() }
    }
    
    
    func view(history controller: UIViewController) {
        guard let controller = controller as? QueueViewController else { return }
        
        controller.user = user.id
        controller.mode = .history
    }
    
    func view(listeners: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.q.rawValue) as? QueueViewController
            else { return }
        
        vc.user = user.id
        vc.mode = .listeners
        
        controller.show(vc, sender: self)
    }
    
    func view(radio: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.q.rawValue) as? QueueViewController
            else { return }
        
        vc.user = user.id
        vc.mode = .radio
        
        controller.show(vc, sender: self)
    }
    
    func view(requests: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.q.rawValue) as? QueueViewController
            else { return }
        
        vc.user = user.id
        vc.mode = .requests
        
        controller.show(vc, sender: self)
    }
    
    func vote(song: Song, _ direction: Vote) {
        CliqueAPI.vote(song: song, direction, for: user.id)
    }

}
