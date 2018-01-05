//
//  User.swift
//  Clique
//
//  Created by Phil Hawkins on 1/2/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct User: Codable {
    var username: String
    let id: String
    let queue: Queue
    var library: [Song]
    
    init(_ username: String, id: String, queue: Queue, library: [Song]) {
        self.username = username
        self.id = id
        self.queue = queue
        self.library = library
    }
    
    func clone() -> User {
        return User(username, id: id, queue: queue, library: library)
    }
}

struct Identity {
    static var instance: Identity?
    private var identity: User
    
    static func sharedInstance() -> Identity {
        
        if instance == nil {
            instance = Identity()
        }
        
        return instance!
    }
    
    private init() {
        //TODO: - populate identity
        
    }
}
