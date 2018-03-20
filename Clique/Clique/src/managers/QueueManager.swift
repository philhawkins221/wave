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
        
        controller.profilebar?.manage(profile: user)
    }
    
    //MARK: - mutators
    
    func manage(user: User) {
        controller.user = user.id
        controller.profilebar?.manage(profile: user)
        
        update()
    }
    
    func update() {
        controller.refresh()
    }
    
    func update(queue replacement: Queue) {
        CliqueAPI.update(queue: replacement)
        update()
    }
    
    func update(applemusic status: Bool) {
        CliqueAPI.update(applemusic: user, to: status)
        update()
    }
    
    func update(spotify status: Bool) {
        CliqueAPI.update(spotify: user, to: status)
        update()
    }
    
    func update(voting status: Bool) {
        CliqueAPI.update(voting: user, to: status)
        update()
    }
    
    //MARK: - accessors
    
    func client() -> User {
        var client = user
        if client.queue.voting { client.queue.queue.sort(by: { $0.votes > $1.votes }) }
        
        return client
    }
    
    //MARK: - actions
    
    func add(song: Song) {
        if user.me() {
            CliqueAPI.add(song: song, to: user)
        } else {
            //TODO: alert
        }
    }
    
    func advance() {
        player.pause()
        if let next = CliqueAPI.advance(queue: user) { play(song: next) }
        else { play() } //might not be right
        
    }
    
    func play() {
        print("queue is empty")
        //TODO: play
    }
    
    func play(song: Song) {
        CliqueAPI.play(song: song, for: user)
        Media.play(song: song)
    }
    
    func play(playlist: Playlist, at index: Int) {
        play(song: playlist.songs[index])
        controller.fill = playlist
        
        update()
    }
    
    func search(on controller: UIViewController) {
        guard let controller = controller as? BrowseViewController else { return }
        
        controller.adding = true
        controller.final = false
        controller.navigationItem.prompt = "adding song to queue"
        controller.user = Identity.me
        controller.mode = .friends
    }
    
    func find(song: Song) {
        add(song: song)
        
        Media.find()
        controller.navigationController?.popToViewController(controller, animated: true)
    }
    
    func view(history controller: UIViewController) {
        guard let controller = controller as? QueueViewController else { return }
        
        controller.user = user.id
        controller.mode = .history
    }
    
    func vote(song: Song, _ direction: Vote) {
        CliqueAPI.vote(song: song, direction, for: user)
    }

}
