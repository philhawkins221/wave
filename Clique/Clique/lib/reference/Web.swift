//
//  Web.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_Synchronous
import AlamofireImage
import SwiftyJSON

struct Web {
    
    static func call(_ type: RequestMethod, to endpoint: String, with parameters: [String : Any]? = nil) -> JSON? {
        
        print("calling", type.rawValue, "request to endpoint", endpoint)
        
        let method: HTTPMethod
        switch type {
        case .get: method = .get
        case .put: method = .put
        case .post: method = .post
        case .delete: method = .delete
        }
        
        var response: JSON? = nil
        
        let res = Alamofire.request(endpoint, method: method, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: nil).responseJSON()
        
        if let value = res.result.value {
            response = JSON(value)
        }
        
        //print(response as Any)
        
        return response
    }
    
    static func send(_ type: RequestMethod, to endpoint: String, with parameters: [String : Any]? = nil) {
        
        print("sending", type.rawValue, "request to endpoint", endpoint)
        
        let method: HTTPMethod
        switch type {
        case .get: method = .get
        case .put: method = .put
        case .post: method = .post
        case .delete: method = .delete
        }
        
        Alamofire.request(endpoint, method: method, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: nil).validate().responseJSON { _ in
            
            print("sent")
            
        }
    }
    
    static func parameterize(song: Song) -> [String : Any] {
        return [
            "id": song.id,
            "library": song.library,
            "title": song.title,
            "artist": parameterize(artist: song.artist),
            "sender": song.sender,
            "artwork": song.artwork,
            "votes": song.votes
        ]
    }
    
    static func parameterize(artist: Artist) -> [String : Any] {
        return [
            "id": artist.id,
            "library": artist.library,
            "name": artist.name
        ]
    }
    
    static func parameterize(queue: Queue) -> [String : Any] {
        return [
            "owner": queue.owner,
            "listeners": queue.listeners,
            
            "radio": queue.radio,
            "voting": queue.voting,
            "requestsonly": queue.requestsonly,
            "donotdisturb": queue.donotdisturb,
            
            "queue": queue.queue.map { parameterize(song: $0) },
            "history": queue.history.map { parameterize(song: $0) },
            "requests": queue.requests.map { parameterize(song: $0) },
            "current": (queue.current != nil ? parameterize(song: queue.current!) : nil) as Any
        ]
    }
    
    static func parameterize(playlist: Playlist) -> [String : Any] {
        return [
            "owner": playlist.owner,
            "id": playlist.id,
            "library": playlist.library,
            "name": playlist.name,
            "social": playlist.social,
            "songs": playlist.songs.map { parameterize(song: $0) }
        ]
    }
    
    static func parameterize(request: Request) -> [String : Any] {
        return [
            "sender": request.sender,
            "receiver": request.receiver
        ]
    }
    
    static func parameterize(user: User) -> [String : Any] {
        return [
            "username": user.username,
            "id": user.id,
            "friends": user.friends,
            "requests": user.requests,
            "queue": parameterize(queue: user.queue),
            "library": user.library.map { parameterize(playlist: $0) },
            "applemusic": user.applemusic,
            "spotify": user.spotify
        ]
    }
    
    static func get(image url: String) -> UIImageView? {
        guard let location = URL(string: url) else { return nil }
        let placeholder = UIImage(named: "genericart.png")
        
        let image = UIImageView()
        image.af_setImage(withURL: location, placeholderImage: placeholder)
        
        return image
    }
    
}
