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

protocol LibrarySearching {
    static func search(_ term: String) -> [Song]
    static func find(id: String) -> Song?
}

//MARK: - utilities

struct Utility {
    
    static func sendRequest(type: RequestMethod, to endpoint: String, with parameters: [String : Any]?) -> JSON? {
        
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
        
        return response
    }
        
    
    //TODO: - set table view cell image size utility function
    static func setTableViewCellImageSize(to size: Int, on cell: UITableViewCell) {
        
    }
}

struct AppleMusicAPIUtility: LibrarySearching {
    static func search(_ term: String) -> [Song] {
        var results = [Song]()
        let endpoint = Endpoints.AppleMusic.searchpoint + term + Endpoints.AppleMusic.searchparameters
        
        if let response = Utility.sendRequest(type: .get, to: endpoint, with: nil) {
            let songs = response["results"]["songs"]["data"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: song["attributes"]["artistName"].string ?? "",
                    artwork: song["attributes"]["artwork"]["url"].string ?? "")
                )
            }
        }
        
        return results
    }
    
    static func find(id: String) -> Song? {
        let result: Song?
        let endpoint = Endpoints.AppleMusic.songpoint + id
        
        check: if let response = Utility.sendRequest(type: .get, to: endpoint, with: nil) {
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

struct SpotifyAPIUtility: LibrarySearching {
    static func search(_ term: String) -> [Song] {
        <#code#>
    }
    
    static func find(id: String) -> Song? {
        <#code#>
    }
}

struct iTunesAPIUtility {
    
}

struct CliqueAPIUtility {
    static func add(song: Song, to clique: String) {
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
    }
}
