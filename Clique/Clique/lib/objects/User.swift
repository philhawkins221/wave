//
//  User.swift
//  Clique
//
//  Created by Phil Hawkins on 1/2/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct User: Codable, Equatable {
    
    var username: String
    let id: String
    var friends: [String]
    var requests: [Request]
    var queue: Queue
    var library: [Playlist]
    var applemusic: Bool
    var spotify: Bool
    
    init(_ username: String, id: String, friends: [String], requests: [Request], queue: Queue, library: [Playlist], applemusic: Bool, spotify: Bool) {
        self.username = username
        self.id = id
        self.friends = friends
        self.requests = requests
        self.queue = queue
        self.library = library
        self.applemusic = applemusic
        self.spotify = spotify
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        if lhs.id == rhs.id { return true }
        
        return false
    }
    
    func me() -> Bool {
        return id == Identity.me
    }

}
