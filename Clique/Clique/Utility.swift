//
//  Utility.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//MARK: - protocols

protocol Searching {
    static func search(_ term: String) -> [CatalogItem] //[Any]
    //static func find(id: String) -> Song?
}

//MARK: - utilities

struct WebUtility {
    
    static func sendRequest(type: RequestMethod, to endpoint: String, with parameters: [String : Any]?) -> JSON? {
        
        print("sending", type.rawValue, "request to endpoint", endpoint)
        
        let method: HTTPMethod
        switch type {
        case .get: method = .get
        case .put: method = .put
        case .post: method = .post
        }
        
        var response: JSON?
        
        Alamofire.request(endpoint, method: method, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: nil).responseJSON {
            
            if let value = $0.result.value {
                response = JSON(value)
            }
        }
        
        print(response as Any)
        
        return response
    }
    
}

struct QueueUtility {
    static func queue(song: Song, to user: User) {
        var replacement = user.queue.queue
        replacement.append(song)
        
        let queue = Queue(
            radio: user.queue.radio,
            voting: user.queue.voting,
            requestsonly: user.queue.requestsonly,
            donotdisturb: user.queue.donotdisturb,
            queue: replacement,
            history: user.queue.history,
            current: user.queue.current,
            listeners: user.queue.listeners)
        
        CliqueAPIUtility.update(queue: user, with: queue)
    }
    
    static func advance(queue user: User) {
        var newhistory = user.queue.history
        var newqueue = user.queue.queue
        
        newhistory.insert(user.queue.current, at: 0)
        let newcurrent = newqueue.removeFirst()
        
        let replacement = Queue(
            radio: user.queue.radio,
            voting: user.queue.voting,
            requestsonly: user.queue.requestsonly,
            donotdisturb: user.queue.donotdisturb,
            queue: newqueue,
            history: newhistory,
            current: newcurrent,
            listeners: user.queue.listeners)
        
        CliqueAPIUtility.update(queue: user, with: replacement)
        
    }
    
    static func vote(song: Song, _ direction: Vote, in queue: Queue, of user: User) {
        
        //vote
        
        //update queue
    }
}

struct AppleMusicAPIUtility: Searching {
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.AppleMusic.searchpoint(term)
        
        if let response = WebUtility.sendRequest(type: .get, to: endpoint, with: nil) {
            let songs = response["results"]["songs"]["data"].array ?? []
            let artists = response["results"]["artists"]["data"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: song["attributes"]["artistName"].string ?? "",
                    artwork: song["attributes"]["artwork"]["url"].string ?? "")
                )
            }
            
            for artist in artists {
                results.append(Artist(id: artist["id"].string ?? ""))
            }
        }
        
        return results
    }
    
    static func find(id: String) -> Song? {
        let result: Song?
        let endpoint = Endpoints.AppleMusic.songpoint(id)
        
        check: if let response = WebUtility.sendRequest(type: .get, to: endpoint, with: nil) {
            guard let song = response["data"].array?[0] else { break check }
            
            result = Song(
                id: song["id"].string ?? "",
                library: Catalogues.AppleMusic.rawValue,
                title: song["attributes"]["name"].string ?? "",
                artist: song["attributes"]["artistName"].string ?? "",
                artwork: song["attributes"]["artwork"]["url"].string ?? "")
        }
        
        return result
    }

}

struct SpotifyAPIUtility: Searching {
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.AppleMusic.searchpoint(term)
        
        if let response = WebUtility.sendRequest(type: .get, to: endpoint, with: nil) {
            let songs = response["tracks"]["items"].array ?? []
            let artists = response["artists"]["items"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: song["attributes"]["artistName"].string ?? "",
                    artwork: song["attributes"]["artwork"]["url"].string ?? "")
                )
            }
            
            for artist in artists {
                results.append(Artist(id: artist["id"].string ?? ""))
            }
        }
        
        return results
    }
}

struct iTunesAPIUtility {
    static func match(_ song: Song) -> Song? {
        let result: Song?
        
        let term = song.artist + " " + song.title
        let endpoint = Endpoints.iTunes.searchpoint(term)
        
        if let response = WebUtility.sendRequest(type: .get, to: endpoint, with: nil) {
            let match = response["results"].array?.first ?? []
            result = Song(
                id: song.id,
                library: Catalogues.Library.rawValue,
                title: match["trackName"].string ?? "",
                artist: match["artistName"].string ?? "",
                artwork: match["artworkUrl60"].string ?? "")
        }
        
        return result
    }
}

struct CliqueAPIUtility {
    
    static func find(user id: String) -> User? {
        
    }
    
    static func search(user username: String) -> [User] {
    
    }
    
    static func update(queue user: User, with replacement: Queue) {
        //make songlist the queue
    }
    
    static func update(library user: User, with replacement: [Song]) {
        var clone = user.clone()
        clone.library = replacement
    }
    
    //static func add(song: Song, to clique: String) {
        
        //get clique with id
        //Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON()
       
        //replace songlist with new list
        //Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateClique", parameters: ["songList": newlist], encoding: .JSON)
        
        //mark upcoming song as played -- need to change to not take parameters?
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/markSongAsPlayed", parameters: p1, encoding: .JSON)
        
        //update current song
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/changeSong", parameters: p2, encoding: .JSON)
        
        //upvote -- need to change to id based
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/upvote", parameters: p, encoding: .JSON)
 
        //downvote -- need to change to id based
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/downvote", parameters: p, encoding: .JSON)
        
        //load songs into library
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/loadSongs", parameters: newlib, encoding: .JSON).responseJSON { response in
            //dispatch_async(dispatch_get_main_queue(), {
                //self.table.reloadData()
            //})
        //}
    
        //create new user
        //Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/", parameters: newclique, encoding: .JSON)
    //}
        //load all playlists
        //"http://clique2016.herokuapp.com/playlists"
}
