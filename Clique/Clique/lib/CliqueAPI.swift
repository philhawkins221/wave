//
//  CliqueAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct CliqueAPI {
    
    static func new(user: User) -> User? {
        let endpoint = Endpoints.Clique.newpoint
        let parameters = Web.parameterize(user: user)
        
        if let response = Web.call(.post, to: endpoint, with: parameters) {
            return try? JSONDecoder().decode(User.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func find(user id: String) -> User? {
        let endpoint = Endpoints.Clique.findpoint(id)
        
        if let response = Web.call(.get, to: endpoint) {
            return try? JSONDecoder().decode(User.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func search(user username: String) -> [User] {
        var results = [User]()
        let endpoint = Endpoints.Clique.allpoint
        
        if let response = Web.call(.get, to: endpoint) {
            let users = response.array ?? []
            for user in users {
                if let result = try? JSONDecoder().decode(User.self, from: user.rawData()) {
                    if result.username.contains(username) {
                        results.append(result)
                    }
                }
            }
        }
        
        return results
    }
    
    static func play(song: Song, for user: User) {
        let endpoint = Endpoints.Clique.playpoint(user.id)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func stop(user: User) {
        let endpoint = Endpoints.Clique.playpoint(user.id)
        //TODO: stop
    }
    
    static func advance(queue user: User) -> Song? {
        let endpoint = Endpoints.Clique.advancepoint(user.id)
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            return try? JSONDecoder().decode(Song.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func vote(song: Song, _ direction: Vote, for user: User) {
        let endpoint = Endpoints.Clique.votepoint(user.id, direction)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func add(song: Song, to user: User) {
        let endpoint = Endpoints.Clique.add.songpoint(user.id)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func add(friend: String, to user: User) {
        let endpoint = Endpoints.Clique.add.friendpoint(user.id)
        let parameters: [String : Any] = ["id": friend]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(user replacement: User) {
        let endpoint = Endpoints.Clique.update.userpoint(replacement.id)
        let parameters = Web.parameterize(user: replacement)
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(queue replacement: Queue) {
        let endpoint = Endpoints.Clique.update.queuepoint(replacement.owner)
        let parameters = Web.parameterize(queue: replacement)
        
        let _ = Web.call(.post, to: endpoint, with: parameters)
    }
    
    static func update(library user: User, with replacement: [Playlist]) {
        let endpoint = Endpoints.Clique.update.librarypoint(user.id)
        let parameters: [String : Any] = ["library": replacement.map { Web.parameterize(playlist: $0) }]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(playlist user: User, with replacement: Playlist) {
        let endpoint = Endpoints.Clique.update.playlistpoint(user.id)
        let parameters = Web.parameterize(playlist: replacement)
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(applemusic user: User, to status: Bool) {
        let endpoint = Endpoints.Clique.update.applemusicpoint(user.id)
        let parameters: [String : Any] = ["value": status]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(spotify user: User, to status: Bool) {
        let endpoint = Endpoints.Clique.update.spotifypoint(user.id)
        let parameters: [String : Any] = ["value": status]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(voting user: User, to status: Bool) {
        let endpoint = Endpoints.Clique.update.votingpoint(user.id)
        let parameters: [String : Any] = ["value": status]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func delete(user: User) {
        let endpoint = Endpoints.Clique.delete.userpoint(user.id)
        let _ = Web.call(.delete, to: endpoint)
    }
    
    static func delete(playlist: Playlist, for user: User) {
        let endpoint = Endpoints.Clique.delete.playlistpoint(user.id)
        let _ = Web.call(.delete, to: endpoint)
    }
    
    static func delete(friend: String, for user: User) {
        let endpoint = Endpoints.Clique.delete.friendpoint(user.id)
        let _ = Web.call(.delete, to: endpoint)
    }
    
}
