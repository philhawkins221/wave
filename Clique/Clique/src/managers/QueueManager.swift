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
        }
        
        controller.profilebar.manage(profile: user)
    }
    
    //MARK: - tasks

    func add(song: Song) {
        var song = song
        if song.sender == "" { song.sender = Identity.me }
        return user.queue.requestsonly && !user.me() ?
            CliqueAPI.request(song: song, to: user.id) :
            CliqueAPI.add(song: song, to: user.id)
    }
    
    func advance() {
        player.pause()
        if let next = CliqueAPI.advance(queue: user.id) { play(song: next) }
        else { play() } //TODO: might not be right
        
    }
    
    func client() -> User {
        var client = user
        if client.queue.voting { client.queue.queue.sort(by: { $0.votes > $1.votes }) }
        
        return client
    }
    
    func find(song: Song, from controller: BrowseViewController, confirmed: Bool) {
        guard confirmed else { return Alerts.queue(song: song, on: controller) }
        
        add(song: song)
        Media.find()
        self.controller.navigationController?.popToViewController(self.controller, animated: true)
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

    func play() {
        print("queue is empty")
        //TODO: play
    }
    
    func play(playlist: Playlist, at index: Int) {
        play(song: playlist.songs[index])
        controller.fill = playlist
        
        refresh()
    }
    
    func play(song: Song) {
        CliqueAPI.play(song: song, for: user.id)
        Media.play(song: song)
    }
    
    func refresh() {
        controller.refresh()
    }
    
    func search(on controller: UIViewController) {
        guard let controller = controller as? BrowseViewController else { return }
        
        controller.adding = true
        controller.final = false
        controller.navigationItem.prompt = !user.me() && user.queue.requestsonly ? "requesting song" : "adding song to queue"
        controller.user = Identity.me
        controller.mode = .friends
    }
    
    func shuffle(enabled: Bool = true) {
        controller.shuffle = enabled
        refresh()
    }
    
    func stop() {
        //TODO: stop
    }
    
    func update(listeners replacement: [String], refresh: Bool = true) {
        CliqueAPI.update(listeners: replacement, for: user.id)
        if refresh { self.refresh() }
    }
    
    func update(queue replacement: Queue, refresh: Bool = true) {
        CliqueAPI.update(queue: replacement)
        if refresh { self.refresh() }
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
    
    func vote(song: Song, _ direction: Vote) {
        CliqueAPI.vote(song: song, direction, for: user.id)
    }

}
