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
    
    static private var instance: QueueManager?
    
    private var user: User?
    var controller: QueueViewController?
    var delegate: QueueDelegate
    var fill: Playlist?
    
    //MARK: - initializers
    
    static func sharedInstance() -> QueueManager {
        
        if instance == nil {
			instance = QueueManager()
		}
		
        return instance!
    }
    
    private init() {
        //TODO: populate with music player queue
        user = Identity.sharedInstance().me
        delegate = QueueDelegate()
    }
    
    //MARK: - mutators
    
    static func manage(user: User) throws {
        switch instance {
        case nil: throw ManagementError.unsetInstance
        default:
            instance?.user = user
            instance?.controller?.profilebar.manage(profile: user)
        }
    }
    
    static func manage(fill: Playlist) throws {
        switch instance {
        case nil: throw ManagementError.unsetInstance
        default: instance?.fill = fill
        }
    }
    
    static func manage(controller: QueueViewController) throws {
        switch instance {
        case nil: throw ManagementError.unsetInstance
        default: instance?.controller = controller
        }
    }
    
    //MARK: - accessors
    
    func client() -> User? {
        refresh()
        
        var clone = user?.clone()
        if clone?.queue.voting ?? false { clone?.queue.queue.sort(by: { $0.votes > $1.votes }) }
        
        return clone
    }
    
    //MARK: - actions
    
    private func refresh() {
        if let found = CliqueAPIUtility.find(user: user?.id ?? "") {
            try? QueueManager.manage(user: found)
        }
    }
    
    func add(song: Song) {        
        CliqueAPIUtility.add(song: song, to: user)
    }
    
    func advance() {
        if let next = CliqueAPIUtility.advance(queue: user) { play(song: next) }
        else { empty() }
        
    }
    
    func update(with addition: Song? = nil, to result: Queue? = nil) {
        guard let user = client() else { return }
        
        //result
        if let result = result {
            CliqueAPIUtility.update(queue: user, with: result)
            refresh()
            
            return
        }
        
        //additions
        if let addition = addition {
            CliqueAPIUtility.add(song: addition, to: user)
        }
        
        refresh()
    }
    
    func vote(song: Song, _ direction: Vote) {
        CliqueAPIUtility.vote(song: song, direction, for: user)
    }
    
    func play(song: Song) {
        
    }
    
    private func empty() {
        
    }

}
