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
    
    static func search(user username: String, strict: Bool = false) -> [User] {
        var results = [User]()
        let endpoint = Endpoints.Clique.allpoint
        
        if let response = Web.call(.get, to: endpoint) {
            let users = response.array ?? []
            for user in users {
                if let result = try? JSONDecoder().decode(User.self, from: user.rawData()) {
                    if strict, username == result.username {
                        results.append(result)
                    } else if result.username.lowercased().contains(username.lowercased()) {
                        results.append(result)
                    }
                }
            }
        }
        
        return results
    }
    
    static func play(song: Song, for user: String) {
        let endpoint = Endpoints.Clique.playpoint(user)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func stop(user: String) {
        let endpoint = Endpoints.Clique.stoppoint(user)
        let _ = Web.call(.get, to: endpoint)
    }
    
    static func advance(queue user: String) -> Song? {
        let endpoint = Endpoints.Clique.advancepoint(user)
        
        if let response = Web.call(.get, to: endpoint) {
            return try? JSONDecoder().decode(Song.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func vote(song: Song, _ direction: Vote, for user: String) {
        let endpoint = Endpoints.Clique.votepoint(user, direction)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func add(song: Song, to user: String) {
        let endpoint = Endpoints.Clique.add.songpoint(user)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func add(friend: String, to user: String) {
        let endpoint = Endpoints.Clique.add.friendpoint(user)
        let parameters: [String : Any] = ["id": friend]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func add(listener: String, to user: String) {
        let endpoint = Endpoints.Clique.add.listenerpoint(user)
        let parameters: [String : Any] = ["id": listener]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func delete(user: String) {
        let endpoint = Endpoints.Clique.delete.userpoint(user)
        let _ = Web.call(.delete, to: endpoint)
    }
    
    static func delete(playlist: Playlist, for user: String) {
        let endpoint = Endpoints.Clique.delete.playlistpoint(user)
        let parameters = Web.parameterize(playlist: playlist)
        
        let _ = Web.call(.delete, to: endpoint, with: parameters)
    }
    
    static func delete(friend: String, for user: String) {
        let endpoint = Endpoints.Clique.delete.friendpoint(user)
        let parameters: [String : Any] = ["id": friend]
        
        let _ = Web.call(.delete, to: endpoint, with: parameters)
    }
    
    static func refresh(user id: String, on controller: UIViewController) -> User? {
        let endpoint = Endpoints.Clique.findpoint(id)
        
        if let response = Web.call(.get, to: endpoint) {
            return try? JSONDecoder().decode(User.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func request(friend request: Request) {
        let endpoint = Endpoints.Clique.request.friendpoint(request.receiver)
        let parameters = Web.parameterize(request: request)
        
        Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func request(song request: Song, to user: String) {
        let endpoint = Endpoints.Clique.request.songpoint(user)
        let parameters = Web.parameterize(song: request)
        
        Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func update(friendRequests replacement: [Request], for user: String) {
        let endpoint = Endpoints.Clique.update.requestspoint(user)
        let parameters: [String : Any] = ["replacement": replacement.map { Web.parameterize(request: $0) }]
        
        Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func update(songRequests replacement: [Song], for user: String) {
        let endpoint = Endpoints.Clique.update.songrequestspoint(user)
        let parameters: [String : Any] = ["replacement": replacement.map { Web.parameterize(song: $0) }]
        
        Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func update(listeners replacement: [String], for user: String) {
        let endpoint = Endpoints.Clique.update.listenerspoint(user)
        let parameters: [String : Any] = ["replacement": replacement]
        
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
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(library user: String, with replacement: [Playlist]) {
        let endpoint = Endpoints.Clique.update.librarypoint(user)
        let parameters: [String : Any] = ["library": replacement.map { Web.parameterize(playlist: $0) }]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(playlist user: String, with replacement: Playlist) {
        let endpoint = Endpoints.Clique.update.playlistpoint(user)
        let parameters = Web.parameterize(playlist: replacement)
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(applemusic user: String, to status: Bool) {
        let endpoint = Endpoints.Clique.update.applemusicpoint(user)
        let parameters: [String : Any] = ["value": status]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(spotify user: String, to status: Bool) {
        let endpoint = Endpoints.Clique.update.spotifypoint(user)
        let parameters: [String : Any] = ["value": status]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(username user: String, to username: String) {
        let endpoint = Endpoints.Clique.update.usernamepoint(user)
        let parameters: [String : Any] = ["name": username]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(voting user: String, to status: Bool) {
        let endpoint = Endpoints.Clique.update.votingpoint(user)
        let parameters: [String : Any] = ["value": status]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
}
