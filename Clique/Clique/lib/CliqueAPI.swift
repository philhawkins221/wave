//
//  CliqueAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct CliqueAPI {
    
    static func find(user id: String?) -> User? {
        guard let id = id else { return nil }
        
        let endpoint = Endpoints.Clique.findpoint(id)
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            return try? JSONDecoder().decode(User.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func search(user username: String) -> [User] {
        var results = [User]()
        let endpoint = Endpoints.Clique.searchpoint
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
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
    
    static func add(song: Song, to user: User?) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }
        
        let endpoint = Endpoints.Clique.addpoint(user.id)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func advance(queue user: User?) -> Song? {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }
        
        let endpoint = Endpoints.Clique.advancepoint(user.id)
        
        if let response = Web.call(.put, to: endpoint, with: nil) {
            return try? JSONDecoder().decode(Song.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func play(song: Song, for user: User?) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }
        
        let endpoint = Endpoints.Clique.playpoint(user.id)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func stop(user: User?) {
        //TODO: stop - set current to null
    }
    
    static func vote(song: Song, _ direction: Vote, for user: User?) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }
        
        let endpoint = Endpoints.Clique.votepoint(user.id, direction)
        let parameters = Web.parameterize(song: song)
        
        let _ = Web.send(.put, to: endpoint, with: parameters)
    }
    
    static func update(user replacement: User?) {
        guard let replacement = replacement else {
            fatalError(ManagementError.unidentifiedUser.rawValue)
        }
        
        let endpoint = Endpoints.Clique.update.userpoint(replacement.id)
        let parameters = Web.parameterize(user: replacement)
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(queue user: User?, with replacement: Queue) {
        guard let user = user else {
            fatalError(ManagementError.unidentifiedUser.rawValue)
        }
        
        let endpoint = Endpoints.Clique.update.queuepoint(user.id)
        let parameters = Web.parameterize(queue: replacement)
        
        let _ = Web.call(.post, to: endpoint, with: parameters)
    }
    
    static func update(library user: User?, with replacement: [Playlist]) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }
        
        let endpoint = Endpoints.Clique.update.librarypoint(user.id)
        let parameters: [String : Any] = ["library": replacement.map { Web.parameterize(playlist: $0) }]
        
        let _ = Web.call(.put, to: endpoint, with: parameters)
    }
    
    static func new(user: User) -> User? {
        let endpoint = Endpoints.Clique.newpoint
        let parameters = Web.parameterize(user: user)
        
        if let response = Web.call(.post, to: endpoint, with: parameters) {
            return try? JSONDecoder().decode(User.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func delete(user: User?) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }
        
        let endpoint = Endpoints.Clique.deletepoint(user.id)
        
        let _ = Web.call(.delete, to: endpoint, with: nil)
    }
    
}
