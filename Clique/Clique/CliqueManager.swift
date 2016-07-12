//
//  CliqueManager.swift
//  Clique
//
//  Created by Phil Hawkins on 7/8/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

var currentclique: (id: String, leader: Bool, name: String, passcode: String, applemusic: Bool, spotify: Bool, voting: Bool) = ("", false, "", "", false, false, true) {

didSet {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    //2
    let cliqueRequest: NSFetchRequest
    if privatelistening {
        cliqueRequest = NSFetchRequest(entityName: "Playlist")
    } else {
        cliqueRequest = NSFetchRequest(entityName:"Clique")
    }
    
    //3
    do {
        let cliques = try managedContext.executeFetchRequest(cliqueRequest) as! [NSManagedObject]
        
        for clique in cliques {
            if (clique.valueForKey("id") as! String) == currentclique.id {
                print("saving new clique information:", currentclique)
                clique.setValue(currentclique.name, forKey: "name")
                clique.setValue(currentclique.passcode, forKey: "passcode")
                clique.setValue(currentclique.leader, forKey: "isLeader")
                clique.setValue(currentclique.applemusic, forKey: "applemusic")
                clique.setValue(currentclique.spotify, forKey: "spotify")
                clique.setValue(currentclique.voting, forKey: "voting")
                
                appDelegate.saveContext()
                
                break
            }
        }
    } catch {
        print(error)
    }
    
    if !currentclique.leader || currentclique.id != oldValue.id {
        return
    }
    
    if currentclique.applemusic != oldValue.applemusic {
        Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateAppleMusicStatus", parameters: ["value": currentclique.applemusic], encoding: .JSON)
    }
    
    if currentclique.spotify != oldValue.spotify {
        Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateSpotifyStatus", parameters: ["value": currentclique.spotify], encoding: .JSON)
    }
    
    if currentclique.voting != oldValue.voting {
        Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateVotingStatus", parameters: ["value": currentclique.voting], encoding: .JSON)
    }
    
    if currentclique.applemusic || currentclique.spotify {
        emptydirective = .magic
    }
}

}

enum CliqueEditAction {
    case Delete
    case Reorder
}

class CliqueManager {
    
    static var instance: CliqueManager?
    
    var clique: [(song: String, artist: String, artwork: String?, votes: Int, voting_available: Bool)]
    //var currentSong: (name: String, artist: String, artwork: String) = ("", "", "")
    
    var cliquejson = [String : AnyObject]()
    
    private init() {
        clique = [(song: String, artist: String, artwork: String?, votes: Int, voting_available: Bool)]()
    }
    
    static func sharedInstance() -> CliqueManager {
        if instance == nil {
            instance = CliqueManager()
        }
        
        return instance!
    }
    
    func fetch() {
        print("fetching")
        clique.removeAll()
        cliquejson.removeAll()
        
        //step 1: check "voting" status in clique, and rearrange clique as needed
        if currentclique.leader && currentclique.voting {
            Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)

                        let songlist = json["songList"].array ?? []
                        var played = [JSON]()
                        var upcoming = [JSON]()
                        
                        for song in songlist {
                            if song["played"].boolValue {
                                played.append(song)
                            } else {
                                upcoming.append(song)
                            }
                        }
                        
                        upcoming.sortInPlace({ $0["votes"].int ?? 0 > $1["votes"].int ?? 0 })
                        
                        var newlist = [[String : AnyObject]]()
                        
                        for song in played {
                            let info: [String : AnyObject] = [
                                "name": song["name"].string ?? "",
                                "artist": song["artist"].string ?? "",
                                "mpid": song["mpid"].string ?? "",
                                "ytid": song["ytid"].string ?? "",
                                "amid": song["amid"].string ?? "",
                                "spid": song["spid"].string ?? "",
                                "scid": song["scid"].string ?? "",
                                "votes": song["votes"].int ?? 0,
                                "played": true,
                                "radio": song["radio"].bool ?? false
                            ]
                            newlist.append(info)
                        }
                        
                        for song in upcoming {
                            let info: [String : AnyObject] = [
                                "name": song["name"].string ?? "",
                                "artist": song["artist"].string ?? "",
                                "mpid": song["mpid"].string ?? "",
                                "ytid": song["ytid"].string ?? "",
                                "amid": song["amid"].string ?? "",
                                "spid": song["spid"].string ?? "",
                                "scid": song["scid"].string ?? "",
                                "votes": song["votes"].int ?? 0,
                                "played": false,
                                "radio": song["radio"].bool ?? false
                            ]
                            newlist.append(info)
                        }
                        
                        self.cliquejson["songList"] = newlist
                        
                        Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateClique", parameters: self.cliquejson, encoding: .JSON)
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
        
        //step 2: get current song
//        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
//            switch response.result {
//            case .Success:
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.currentSong = (json["currentSong"].string ?? "", json["artist"].string ?? "", "")
//                    })
//                }
//            case .Failure(let error):
//                print(error)
//            }
//        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var prime = [(song: String, artist: String, artwork: String?, votes: Int)]()
        var song = ""
        var artist = ""
        var votes = 0
        
        //step 3: pull the next songs - get the stored artist and song name
        session.dataTaskWithURL(NSURL(string: "https://clique2016.herokuapp.com/playlists/" + currentclique.id)!, completionHandler: {(data, response, error) in
            if data == nil {
                print("no data")
                return
            }
            let json = JSON(data: data!)
            //dispatch_async(dispatch_get_main_queue(), { self.title = json["name"].stringValue })
            
            let list = json["songList"].array ?? []
            
            for item in list {
                if item["played"].boolValue {
                    continue
                }
                
                song = item["name"].string ?? "No Title"
                artist = item["artist"].string ?? "No Artist"
                votes = item["votes"].int ?? 0
                
                prime.append((song, artist, nil, votes))
            }
            
            //check if the fetch came back empty
            if song == "" && artist == "" {
                NSNotificationCenter.defaultCenter().postNotificationName("CliqueUpdated", object: self)
                
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.spotifetch(prime)
            })
        }).resume()
    }
    
    func spotifetch(prime: [(song: String, artist: String, artwork: String?, votes: Int)]) {
        func plus(string: String) -> String {
            var result = ""
            
            for c in string.characters {
                if c == " " {
                    result += "+"
                } else {
                    result.append(c)
                }
            }
            
            result = result.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? ""
            return result
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        //step 4: verify names and find album+artwork - spotify api
        for song in prime {
            
            let plussong = plus(song.song)
            let plusartist = plus(song.artist)
            
            session.dataTaskWithURL(NSURL(string: "https://api.spotify.com/v1/search?q=track:" + plussong + "%20artist:" + plusartist + "&type=track&limit=1")!, completionHandler: {(data, response, error) in
                if data == nil {
                    print("no data")
                    return
                }
                let json = JSON(data: data!)
                
                var title = String?()
                var artist = String?()
                var cover = String?()
                
                var newentry: (song: String, artist: String, artwork: String?, votes: Int, voting_available: Bool) = ("", "", nil, song.votes, true)
                
                title = json["tracks"]["items"][0]["name"].string
                artist = json["tracks"]["items"][0]["artists"][0]["name"].string
                cover = json["tracks"]["items"][0]["album"]["images"][0]["url"].string
                
                if title != nil {newentry.song = title!} else {newentry.song = song.song}
                if artist != nil {newentry.artist = artist!} else {newentry.artist = song.artist}
                
                if cover != nil {newentry.artwork = cover!}
                
                self.clique.append(newentry)
                
                //let em know
                NSNotificationCenter.defaultCenter().postNotificationName("CliqueUpdated", object: self)
            }).resume()
        }
    }
    
    func updateClique(forAction action: CliqueEditAction, sourceIndex: Int, destinationIndex: Int = 0) {
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let songlist = json["songList"].array ?? []
                    var played = [JSON]()
                    var upcoming = [JSON]()
                    
                    for song in songlist {
                        if song["played"].boolValue {
                            played.append(song)
                        } else {
                            upcoming.append(song)
                        }
                    }
                    
                    var newlist = [[String : AnyObject]]()
                    
                    for song in played {
                        let info: [String : AnyObject] = [
                            "name": song["name"].string ?? "",
                            "artist": song["artist"].string ?? "",
                            "mpid": song["mpid"].string ?? "",
                            "ytid": song["ytid"].string ?? "",
                            "amid": song["amid"].string ?? "",
                            "spid": song["spid"].string ?? "",
                            "scid": song["scid"].string ?? "",
                            "votes": song["votes"].int ?? 0,
                            "played": true,
                            "radio": song["radio"].bool ?? false
                        ]
                        newlist.append(info)
                    }
                    
                    for song in upcoming {
                        let info: [String : AnyObject] = [
                            "name": song["name"].string ?? "",
                            "artist": song["artist"].string ?? "",
                            "mpid": song["mpid"].string ?? "",
                            "ytid": song["ytid"].string ?? "",
                            "amid": song["amid"].string ?? "",
                            "spid": song["spid"].string ?? "",
                            "scid": song["scid"].string ?? "",
                            "votes": song["votes"].int ?? 0,
                            "played": false,
                            "radio": song["radio"].bool ?? false
                        ]
                        newlist.append(info)
                    }
                    
                    switch action {
                    case .Delete:
                        newlist.removeAtIndex(sourceIndex + played.count)
                    case .Reorder:
                        let item = newlist[sourceIndex + played.count]
                        newlist.removeAtIndex(sourceIndex + played.count)
                        newlist.insert(item, atIndex: destinationIndex + played.count)
                    }
                    
                    Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateClique", parameters: ["songList": newlist], encoding: .JSON)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
}