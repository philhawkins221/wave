//
//  QueueManager.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

struct QueueManager {
    
    static var instance: QueueManager?
    private var user: User
    var table: UITableView
    var delegate: QueueDelegate
    var fill: Playlist
    
    static func sharedInstance() -> QueueManager {
        
        if instance == nil {
			instance = QueueManager()
		}
		
        return instance!
    }
    
    private init() {
        //TODO: - populate with music player queue
        
    }
    
    static func manage(user: User) {
        instance?.user = user
    }
    
    static func manage(fill: Playlist) {
        instance?.fill = fill
    }
    
    func client() -> User {
        var clone = user.clone()
        if clone.queue.voting { clone.queue.queue.sort(by: { $0.votes > $1.votes }) }
        
        return clone
    }
    
    func add(song: Song) {
        CliqueAPIUtility.add(song: song, to: user)
    }
    
    func advance() {
        if let next = CliqueAPIUtility.advance(queue: user) { play(song: next) }
        else { empty() }
        
    }
    
    func update(to result: Queue? = nil) {
        //CliqueAPIUtility.update(queue: user, with: result)
    }
    
    func vote(song: Song, _ direction: Vote) {
        CliqueAPIUtility.vote(song: song, direction, for: user)
    }
    
    func play(song: Song) {
        
    }
    
    private func empty() {
        
    }
}
