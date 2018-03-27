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
        guard let found = CliqueAPI.find(user: controller.user) else { return nil }
        
        self.user = found
        self.controller = controller
        
        switch controller.mode {
        case .queue: delegate = QueueDelegate(to: self)
        case .history: delegate = HistoryDelegate(to: self)
        }
        
        controller.profilebar.manage(profile: user)
    }
    
    //MARK: - tasks

    func add(song: Song) {
        //TODO: request if reqestsonly
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
        guard user.me() || user.queue.listeners.contains(Identity.me) else {
            if let me = CliqueAPI.find(user: Identity.me) { manage(user: me) }
            return
        }
        
        controller.user = user.id
        controller.profilebar?.manage(profile: user)
        
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
        controller.navigationItem.prompt = "adding song to queue"
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
    
    func update(queue replacement: Queue) {
        CliqueAPI.update(queue: replacement)
        refresh()
    }
    
    func update(requests replacement: [Song]) {
        CliqueAPI.update(songRequests: replacement, for: user.id)
    }
    
    func update(voting status: Bool) {
        CliqueAPI.update(voting: user.id, to: status)
        refresh()
    }
    
    func view(history controller: UIViewController) {
        guard let controller = controller as? QueueViewController else { return }
        
        controller.user = user.id
        controller.mode = .history
    }
    
    func vote(song: Song, _ direction: Vote) {
        CliqueAPI.vote(song: song, direction, for: user.id)
    }

}
