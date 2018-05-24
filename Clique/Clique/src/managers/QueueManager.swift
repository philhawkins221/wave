//
//  QueueManager.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

///manages a user's information for a `QueueViewController`
struct QueueManager {
    
    //MARK: - properties
    
    ///the user whose information is being managed (cached)
    private let user: User
    ///the view controller on which the user's information is being displayed
    let controller: QueueViewController
    ///the delegate for this manager
    var delegate: QueueDelegate?
    
    ///the current playback source status
    var status: QueueStatus {
        guard let user = CliqueAPI.find(user: user.id) else { return .none }
        
        if !user.me(), let _ = user.queue.current {
            return .streaming
        } else if Media.playing && player.playbackState == .paused {
            return .paused
        } else if !user.queue.queue.isEmpty {
            return .queue
        } else if Settings.takerequests && !user.queue.requests.isEmpty {
            return .requests
        } else if Settings.shuffle && controller.shuffled?.songs.first != nil {
            return .shuffle
        } else if !Settings.shuffle && controller.fill?.songs.first != nil {
            return .fill
        } else if Settings.radio && !q.radio.isEmpty {
            return .radio
        } else if !user.library.isEmpty {
            return .library
        } else {
            return .none
        }
    }
    
    //MARK: - initializers
    
    
    /**
     initializes a `QueueManager` for a given `QueueViewController` and pulls a user from server with the user id provided by the controller. fails if a valid user cannot be found with the user id provided.
     
     - parameters:
        - controller: the controller displaying the user's information
     */
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
        
        if user.me(), Settings.radio, controller.radio.isEmpty { update(radio: ()) }
    }
    
    //MARK: - tasks
    
    /**
     adds a given single to the queue.
     
     - parameters:
        - single: the single to be added
    */
    func add(single: Single) {
        guard let single = iTunesAPI.match(single) else { return Alerts.inform(.canNotQueueSong) }
        add(song: single)
    }

    /**
     adds a given song to the queue.
     
     - parameters:
        - song: the song to be added
     */
    func add(song: Song) {
        var song = song
        if song.sender == "" { song.sender = Identity.me }
        return user.queue.requestsonly && !user.me() ?
            CliqueAPI.request(song: song, to: user.id) :
            CliqueAPI.add(song: song, to: user.id)
    }
    
    ///plays the next song in the queue.
    func advance() {
        Media.stop()
        if let next = CliqueAPI.advance(queue: user.id) { play(song: next) }
        else {
            stop()
            play()
        }
        
    }
    
    /// - returns: the user being managed
    func client() -> User {
        var client = user
        if client.queue.voting { client.queue.queue.sort(by: { $0.votes > $1.votes }) }
        
        return client
    }
    
    /**
     deletes all requests for the user.
     
     - parameters:
        - requests: _
        - confirmed: if the task has been confirmed by the end user, default value is `false`
    */
    func delete(requests: Void, confirmed: Bool = false) {
        guard confirmed else { return Alerts.delete(requests: (), on: controller) }
        
        update(requests: [], refresh: true)
    }
    
    /**
     deletes all songs in the user's queue.
     
     - parameters:
        - queue: _
        - confirmed: if the task has been confirmed by the end user, default value is `false`
    */
    func delete(queue: Void, confirmed: Bool = false) {
        guard confirmed else { return Alerts.delete(queue: (), on: controller) }
        
        var replacement = user.queue
        replacement.queue.removeAll()
        
        update(queue: replacement)
    }
    
    /**
     ends the current search and adds a given song to the queue.
     
     - parameters:
        - song: the song to add
        - controller: the controller displaying the song that was selected
        - confirmed: if the task has been confirmed by the end user, default value is `false`
    */
    func find(song: Song, from controller: BrowseViewController, confirmed: Bool = false) {
        guard confirmed else { return Alerts.queue(song: song, on: controller) }
        
        add(song: song)
        Media.find()
        self.controller.navigationController?.popToViewController(self.controller, animated: true)
    }
    
    /**
     tells the general manager to request a given friend join the queue.
     
     - note:
     the user must match the end user identity
     
     - parameters:
        - friend: the friend to invite
        - confirmed: if the task has been confirmed by the end user, default value is `false`
    */
    func invite(friend: User, confirmed: Bool = false) {
        guard user.me() else { return }
        guard confirmed else { return Alerts.invite(friend: friend, on: controller) }
        
        gm?.request(user: friend.id)
    }
    
    /**
     manages a given user's information.
     
     - parameters:
        - user: the user to manage
     */
    func manage(user: User) {
        guard let user = CliqueAPI.find(user: user.id) else { return }
        guard user.me() || user.queue.listeners.contains(Identity.me) else {
            if let me = CliqueAPI.find(user: Identity.me) { manage(user: me) }
            return
        }
        
        controller.user = user.id
        refresh()
    }
    
    ///pauses playback.
    func pause() {
        if Media.playing { Media.pause() }
        if Spotify.playing { Spotify.pause() }
    }

    ///begins playback based on the current playback source status.
    func play() {
        guard let user = CliqueAPI.find(user: user.id) else { return }
        
        switch status {
        case .streaming:
            guard let current = user.queue.current else { return }
            if !Settings.applemusic { Alerts.inform(.noStreaming, about: user) }
            else if current.library == Catalogues.AppleMusic.rawValue { play(song: current, streaming: true) }
            else if let match = iTunesAPI.match(current) { play(song: match, streaming: true) }
        case .paused:
            Media.play()
        case .queue:
            advance()
        case .requests:
            var replacement = user.queue.requests
            play(song: replacement.first!)
            replacement.remove(at: 0)
            update(requests: replacement)
        case .shuffle:
            play(song: controller.shuffled!.songs.first!)
            controller.shuffled?.songs.remove(at: 0)
        case .fill:
            play(song: controller.fill!.songs.first!)
            controller.fill?.songs.remove(at: 0)
            refresh()
        case .radio:
            play(radio: ())
        case .library:
            var random = user.library.shuffled()
            if Settings.shuffle { random[0].songs.shuffle() }
            play(playlist: random.first!, at: 0)
        case .none:
            stop()
        }
    }
    
    /**
     plays a song in a given playlist.
     
     - note: index must not exceed the list of songs in `playlist`
     - parameters:
        - playlist: the playlist containing the selected song
        - index: the index of the song to play in the list of songs in `playlist`
     */
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
    
    /**
     plays the next single from the radio.
     
     - note: radio must not be empty
     - parameters:
        - radio: _
    */
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
    
    /**
     plays a given single.
     
     - parameters:
        - single: the single to play
     */
    func play(single: Single) {
        guard let single = iTunesAPI.match(single) else { return Alerts.inform(.canNotQueueSong) }
        play(song: single, radio: true)
    }
    
    /**
     plays a given song.
     
     - parameters:
        - song: the song to play
        - streaming: if the user does not match the end user identity, default value is `false`
        - radio: if `song` was sent from the radio, default value is `false`
     */
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
            guard user.applemusic else { return Alerts.inform(.canNotQueueSong) }
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
    
    ///updates the user's information from server.
    ///- note: this manager will be deinitialized
    func refresh() {
        controller.refresh()
    }
    
    ///restarts playback of current song.
    func retreat() {
        if Media.playing {
            player.currentPlaybackTime = 0
        } else if Spotify.playing {
            Spotify.player?.seek(toOffset: 0) { _ in }
        }
    }
    
    /**
     starts a search on top of the current controller.
     
     - note: `controller` must force downcast to `BrowseViewController`
     - parameters:
        - controller: the controller displaying the search
    */
    func search(on controller: UIViewController) {
        guard let controller = controller as? BrowseViewController else { return }
        let streaming = user.applemusic || user.spotify
        
        controller.adding = true
        controller.final = false
        controller.navigationItem.prompt = !user.me() && user.queue.requestsonly ? "requesting song" : "adding song to queue"
        controller.user = streaming ? Identity.me : user.id
        controller.mode = streaming ? .friends : .library
    }
    
    ///stops playback.
    func stop() {
        np.waves.isHidden = false
        
        if user.me() {
            CliqueAPI.stop(user: user.id)
        }
        Media.stop()
        Spotify.stop()
        
        refresh()
    }
    
    /**
     updates thes listeners to server for the user.
     
     - parameters:
        - replacement: the user's updated listeners
        - refresh: if the manager should refresh after the update, default value is `true`
     */
    func update(listeners replacement: [String], refresh: Bool = true) {
        CliqueAPI.update(listeners: replacement, for: user.id)
        if refresh { self.refresh() }
    }
    
    /**
     updates the queue to server for the user.
     
     - parameters:
        - replacement: the user's updated queue
        - refresh: if the manager should refresh after the update, default value is `true`
     */
    func update(queue replacement: Queue, refresh: Bool = true) {
        CliqueAPI.update(queue: replacement)
        if refresh { self.refresh() }
    }
    
    /**
     updates the list of singles from the radio.
     
     - parameters:
        - radio: _
     */
    func update(radio: Void) {
        DispatchQueue.global(qos: .background).async {
            let count = self.user.queue.history.count < 5 ? self.user.queue.history.count : 5
            let seeds = Array(self.user.queue.history.reversed().prefix(count))
            
            self.controller.radio = GracenoteAPI.recommend(from: seeds)
        }
    }
    
    /**
     updates the requests to server for the user.
     
     - parameters:
        - replacement: the user's updated requests
        - refresh: if the manager should refresh after the update, default value is `false`
     */
    func update(requests replacement: [Song], refresh: Bool = false) {
        CliqueAPI.update(songRequests: replacement, for: user.id)
        if refresh { self.refresh() }
    }
    
    /**
     updates the voting status to server for the user.
     
     - parameters:
     - status: if voting is enabled
     - refresh: if the manager should refresh after the update, default value is `true`
     */
    func update(voting status: Bool, refresh: Bool = true) {
        CliqueAPI.update(voting: user.id, to: status)
        if refresh { self.refresh() }
    }
    
    /**
     shows a new controller displaying the songs in the history.
     
     - note: `controller` must force downcast to `QueueViewController`
     - parameters:
        - controller: the controller that will display the history
     */
    func view(history controller: UIViewController) {
        guard let controller = controller as? QueueViewController else { return }
        
        controller.user = user.id
        controller.mode = .history
    }
    
    /**
     shows a new controller displaying the friends listening to the queue.
     
     - parameters:
        - listeners: _
    */
    func view(listeners: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.q.rawValue) as? QueueViewController
            else { return }
        
        vc.user = user.id
        vc.mode = .listeners
        
        controller.show(vc, sender: self)
    }
    
    /**
     shows a new controller displaying the singles on the radio.
     
     - parameters:
        - radio: _
     */
    func view(radio: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.q.rawValue) as? QueueViewController
            else { return }
        
        vc.user = user.id
        vc.mode = .radio
        
        controller.show(vc, sender: self)
    }
    
    /**
     shows a new controller displaying the requests.
     
     - parameters:
        - requests: _
     */
    func view(requests: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.q.rawValue) as? QueueViewController
            else { return }
        
        vc.user = user.id
        vc.mode = .requests
        
        controller.show(vc, sender: self)
    }
    
    /**
     send a vote in a given direction for a given song.
     
     - parameters:
        - song: the song to vote on
        - direction: the direction to vote
    */
    func vote(song: Song, _ direction: Vote) {
        CliqueAPI.vote(song: song, direction, for: user.id)
    }

}
