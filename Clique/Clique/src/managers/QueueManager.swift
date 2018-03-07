//
//  QueueManager.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation
//import MediaPlayer

struct QueueManager {
    
    //MARK: - properties
    
    private var user: User
    var controller: QueueViewController
    var delegate: QueueDelegate?
    
    //MARK: - initializers
    
    init?(to controller: QueueViewController, for user: String = Identity.sharedInstance().me) {
        guard let found = CliqueAPI.find(user: user) else { return nil }
        
        self.user = found
        self.controller = controller
        
        update()
    }
    
    init?(to controller: QueueViewController, with delegate: QueueDelegate, for user: String = Identity.sharedInstance().me) {
        self.init(to: controller, for: user)
        self.delegate = delegate
    }
    
    //MARK: - mutators
    
    mutating func manage(user: User) {
            self.user = user
            controller.profilebar.manage(profile: user)
    }
    
    //MARK: - accessors
    
    func client() -> User {
        var client = user.clone()
        if client.queue.voting { client.queue.queue.sort(by: { $0.votes > $1.votes }) }
        
        return client
    }
    
    mutating func update(with replacement: Queue? = nil) {
        if let replacement = replacement { CliqueAPI.update(queue: user, with: replacement) }
        
        refresh()
    }
    
    private mutating func refresh() {
        guard let found = CliqueAPI.find(user: user.id) else { return }
        
        manage(user: found)
        delegate?.populate()
        controller.table.reloadData()
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
        else { empty() } //might not be right
        
    }
    
    func vote(song: Song, _ direction: Vote) {
        CliqueAPI.vote(song: song, direction, for: user)
    }
    
    func play(song: Song) {
        CliqueAPI.play(song: song, for: user)
        Media.play(song: song)
    }
    
    func play(playlist: Playlist, at index: Int) {
        play(song: playlist.songs[index])
        delegate?.fill = playlist
    }
    
    private func empty() {
        print("queue is empty")
    }

}
