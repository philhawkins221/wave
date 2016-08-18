//
//  PlayerManager.swift
//  Clique
//
//  Created by Phil Hawkins on 5/30/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

import Foundation
import UIKit
import MediaPlayer
import SwiftyJSON
import Alamofire
import Alamofire_Synchronous
import Soundcloud

enum tracktypes {
    case islocal
    case isapplemusic
    case isspotify
    case issoundcloud
    case isyoutube
    case isinactive
}

class PlayerManager {
    
    static var instance: PlayerManager?
    
    var system: MPMusicPlayerController
    var spot: SPTAudioStreamingController
    var spotmanager: SPTAudioStreamingPlaybackDelegate
    var tracktype: tracktypes
    var library: [(song: [String : AnyObject], played: Bool)]
    var magic: [(song: [String : AnyObject], artwork: String, played: Bool)]
    var autoplaying: Bool
    
    var ytid: String
    var mpid: String
    var spid: String
    var amid: String
    var scid: String
    
    private init() {
        
        system = MPMusicPlayerController.systemMusicPlayer()
        spot = SPTAudioStreamingController(clientId: kClientId)
        spotmanager = SpotifyManager()
        tracktype = tracktypes.isinactive
        library = [(song: [String : AnyObject], played: Bool)]()
        magic = [(song: [String : AnyObject], artwork: String, played: Bool)]()
        autoplaying = false
        
        ytid = String()
        mpid = String()
        spid = String()
        amid = String()
        scid = String()
        
        spot.playbackDelegate = spotmanager
    }
    
    static func sharedInstance() -> PlayerManager {
        if instance == nil {
            instance = PlayerManager()
        }
        
        return instance!
    }
    
    func plus(string: String) -> String {
        var result = ""
        
        for c in string.characters {
            if c == " " {
                result += "+"
            } else {
                result.append(c)
            }
        }
        
        result = result.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: "+")) ?? ""
        return result
    }
    
    @objc func fetch() {
        print("fetching")
        system.endGeneratingPlaybackNotifications()
        system.stop()
        PlayerManager.sharedInstance().spot.stop(nil)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        var plussong = String()
        var plusartist = String()
        print(plussong, plusartist)
        
        mpid = ""
        amid = ""
        spid = ""
        ytid = ""
        scid = ""
        
        //step 0: make sure clique is up-to-date
        if currentclique.leader && currentclique.voting {
            let response = Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON()
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
                    
                    Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateClique", parameters: ["songList": newlist], encoding: .JSON)
                }
            case .Failure(let error):
                print(error)
            }
        }
        
        //step 1: pull the next song - get the stored artist and song name
        session.dataTaskWithURL(NSURL(string: "https://clique2016.herokuapp.com/playlists/" + currentclique.id)!, completionHandler: {  (data, response, error) in
            if data == nil {
                print("no data")
                return
            }
            var json = JSON(data: data!)
            print("collected data")
            
            let list = json["songList"].array ?? []
            //print(list)
            
            var song = ""
            var artist = ""
            var i = -1
            
            for item in list {
                i += 1
                
                if item["played"].boolValue {
                    //print("this song has already been played")
                    continue
                }
                
                print(item)
                
                song = item["name"].string ?? ""
                artist = item["artist"].string ?? ""
                self.ytid = item["ytid"].string ?? ""
                self.mpid = item["mpid"].string ?? ""
                self.spid = item["spid"].string ?? ""
                self.amid = item["amid"].string ?? ""
                self.scid = item["scid"].string ?? ""
                
                self.autoplaying = item["radio"].bool ?? false
                
                break
                
                //json["songList"][i]["played"].boolValue = true
            }
            
            //check if the queue is empty
            if self.ytid != "" {
                self.tracktype = .isyoutube
                print("isyoutube")
            } else if self.mpid != "" {
                self.tracktype = .islocal
                print("islocal")
            } else if self.amid != "" {
                self.tracktype = .isapplemusic
                print("isapplemusic")
            } else if self.spid != "" {
                self.tracktype = .isspotify
                print("isspotify")
            } else if self.scid != "" {
                self.tracktype = .issoundcloud
                print("issoundcloud")
            } else {
                self.empty()
                return
            }
            
            plussong = self.plus(song)
            plusartist = self.plus(artist)
            
            
            self.spotifetch(plussong, plusartist: plusartist, usersong: song, userartist: artist)
        }).resume()
    }
    
    func spotifetch(plussong: String, plusartist: String, usersong: String, userartist: String) {
        print("spotifetch")
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        print(plussong, plusartist)
        
        //step 2: verify names and find album+artwork - spotify api
        session.dataTaskWithURL(NSURL(string: "https://api.spotify.com/v1/search?q=track:" + plussong + "%20artist:" + plusartist + "&type=track&limit=1")!, completionHandler: {(data, response, error) in
            if data == nil {
                print("no data")
                return
            }
            let json = JSON(data: data!)
            
            var song = String()
            var artist = String()
            var album = String()
            var artwork = String?()
            
            song = json["tracks"]["items"][0]["name"].string ?? usersong
            artist = json["tracks"]["items"][0]["artists"][0]["name"].string ?? userartist
            album = json["tracks"]["items"][0]["album"]["name"].string ?? ""
            artwork = json["tracks"]["items"][0]["album"]["images"][0]["url"].string
            
            currentsong = (song, artist, album, artwork, 0)
            
            self.prepare()
            
        }).resume()
    }
    
    func prepare() {
        //step 3: prepare the proper player - may need work
        switch tracktype {
        case .isyoutube:
            PlayerViewController.youtubewaiting = true
            
            if (UIApplication.topViewController()?.isKindOfClass(PlayerViewController)) == false {
                let ytalert = UIAlertController(title: "YouTube Link in " + currentclique.name, message: "Open the Clique Player to play this selection from YouTube.", preferredStyle: .Alert)
                ytalert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
                UIApplication.topViewController()?.presentViewController(ytalert, animated: true, completion: nil)
            }
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
                MPMediaItemPropertyTitle: currentsong.song,
                MPMediaItemPropertyArtist: currentsong.artist,
                MPMediaItemPropertyAlbumTitle: currentsong.album,
                MPMediaItemPropertyAlbumArtist: currentsong.artist
            ]
        case .isspotify:
            print("preparing spotify player")
            spot.stop(nil)
            if spot.loggedIn {
                spot.playURI(NSURL(string: self.spid), callback: nil)
            } else {
                spot.loginWithSession(spotifysession, callback: { (error) -> Void in
                    if (error != nil) {
                        print("*** Enabling playback got error: \(error)")
                        currentclique.spotify = false
                        let stopify = UIAlertController(title: "Spotify Authorization Needed", message: "Re-enable Spotify in the Clique settings to resume playback of Spotify content.", preferredStyle: .Alert)
                        stopify.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        
                        dispatch_async(dispatch_get_main_queue(), { UIApplication.topViewController()?.presentViewController(stopify, animated: true, completion: nil) })
                        return
                    } else {
                        print("PlayerManager prepare(): spid = " + self.spid)
                        self.spot.playURI(NSURL(string: self.spid), callback: nil)
                    }
                })
            }
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
                MPMediaItemPropertyTitle: currentsong.song,
                MPMediaItemPropertyArtist: currentsong.artist,
                MPMediaItemPropertyAlbumTitle: currentsong.album,
                MPMediaItemPropertyAlbumArtist: currentsong.artist
            ]
        case .islocal:
            print("preparing system player")
            MPMediaLibrary.defaultMediaLibrary().lastModifiedDate
            system.stop()
            let searcher = MPMediaQuery.songsQuery()
            //searcher.addFilterPredicate(MPMediaPropertyPredicate(value: currentsong.artist, forProperty: MPMediaItemPropertyArtist))
            //searcher.addFilterPredicate(MPMediaPropertyPredicate(value: currentsong.song, forProperty: MPMediaItemPropertyTitle))
            searcher.addFilterPredicate(MPMediaPropertyPredicate(value: Int(mpid), forProperty: MPMediaItemPropertyPersistentID))
            print(searcher.items)
            print(currentsong)
            //system.setQueueWithQuery(searcher)
            system.setQueueWithItemCollection(MPMediaItemCollection(items: searcher.items!))
            system.repeatMode = .None
            system.prepareToPlay()
            system.play()
        case .isapplemusic:
            print("preparing for apple music")
            system.stop()
            if #available(iOS 9.3, *) {
                system.setQueueWithStoreIDs([amid])
                system.prepareToPlay()
                system.play()
            } else {
                // Fallback on earlier versions
                print("gotta have 9.3")
            }
        case .issoundcloud:
            print(scClientID, scClientSecret)
            Track.track(Int(scid)!, completion: {info in }) //use completion handler to update nowplayinginfo?
        default:
            break
        }
        
        //update nowplayinginfocenter
        
        nowplaying = true
        finishup()
    }
    
    func finishup() {
        print("finishup")
        //tell the player that the song changed
        NSNotificationCenter.defaultCenter().postNotificationName("PlayerManagerDidChangeSong", object: self)
        //player should check if isyoutube and get PlayerManager.sharedInstance().ytid
        
        //change song played field
        let p1 = [
            "name": currentsong.song,
            "artist": currentsong.artist
        ]
        
        Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/markSongAsPlayed", parameters: p1, encoding: .JSON)
        
        let p2 = [
            "song": currentsong.song,
            "artist": currentsong.artist
        ]
        
        //update current song
        Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/changeSong", parameters: p2, encoding: .JSON)
        
        system.beginGeneratingPlaybackNotifications()
    }
    
    private func empty() {
        switch emptydirective {
        case .nothing:
            self.tracktype = .isinactive
            print("isinactive")
            currentsong = ("", "", "", "", 0)
            
            let parameters = [
                "song": "",
                "artist": ""
            ]
            Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/changeSong", parameters: parameters, encoding: .JSON)
            
            NSNotificationCenter.defaultCenter().postNotificationName("PlayerManagerDidChangeSong", object: self)
            nowplaying = false
        case .library:
            print("empty directive: selecting song from library")
            
            if autoplaying {
                for i in 0..<library.count {
                    if library[i].played {
                        continue
                    }
                    
                    library[i].played = true
                    Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: library[i].song, encoding: .JSON).responseJSON { response in
                        self.fetch()
                    }
                    
                    return
                }
            }
            
            //fill library
            library.removeAll()
            getLibrary() { [unowned self] in
                self.library.shuffleInPlace()
                
                if !self.library.isEmpty {
                    Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: self.library[0].song, encoding: .JSON).responseJSON { response in
                        self.fetch()
                        self.library[0].played = true
                    }
                }
            }
            
//            let shuffle = {
//                var random = Int(arc4random_uniform(UInt32(self.library.count)))
//                
//                var counter = 0
//                while self.library[random].played {
//                    random = Int(arc4random_uniform(UInt32(self.library.count)))
//                    counter += 1
//                    if counter >= self.library.count {
//                        for i in 0..<self.library.count {
//                            self.library[i].played = false
//                        }
//                    }
//                }
//                print("empty has selected:", self.library[random])
//                let newsong = self.library[random].song
//                self.library[random].played = true
//                
//                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: newsong, encoding: .JSON).responseJSON { response in
//                    self.fetch()
//                }
//            }
//            
//            if library.isEmpty {
//                getLibrary(completionHandler: nil)
//            } else {
//                shuffle()
//            }
            
            
        case .magic:
            print("empty directive: starting clique radio")
            
            //check which catalog will be used
            var usingapplemusic = false
            
            if currentclique.applemusic {
                usingapplemusic = true
            } else if currentclique.spotify {
                usingapplemusic = false
            } else {
                return
            }
            
            //decide to use existing magic playlist
            if autoplaying {
                print("clique radio is ON")
                for i in 0..<magic.count {
                    if magic[i].played {
                        continue
                    }
                    
                    magic[i].played = true
                    Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: magic[i].song, encoding: .JSON).responseJSON { response in
                        self.fetch()
                    }
                    
                    return
                }
            }
            
            //make magic
            print("making magic")
            
            let radioalert = UIAlertController(title: "Starting Clique Radio", message: "Gathering songs based on music played in the Clique. Playback will resume shortly.", preferredStyle: .Alert)
            radioalert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.topViewController()?.presentViewController(radioalert, animated: true, completion: nil)
            })
            
            Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        var songlist = [(song: String, artist: String, votes: Int)]()
                        
                        //get song history
                        for song in json["songList"].array ?? [] {
                            let name = song["name"].string ?? ""
                            let artist = song["artist"].string ?? ""
                            let votes = song["votes"].int ?? 0
                            
                            songlist.append((name, artist, votes))
                        }
                        
                        if songlist.isEmpty { return }
                        
                        var chosen = [(song: String, artist: String, votes: Int)]()
                        
                        //find the song with the most votes
                        let favorite: (song: String, artist: String, votes: Int) = songlist.reduce(("", "", Int.min), combine: {
                            $0.votes > $1.votes ? $0 : $1
                        })
                        if favorite.votes > 0 { chosen.append(favorite) }
                        
                        //get the most recent songs
                        if songlist.count < 3 - chosen.count {
                            chosen += songlist
                        } else {
                            chosen += songlist[songlist.count - (3 - chosen.count)..<songlist.count]
                        }
                        
                        //get artist id for each chosen song
                        var artistids = [String]()
                        
                        for song in chosen {
                            let response = Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=track:" + self.plus(song.song) + "%20artist:" + self.plus(song.artist) + "&type=track&limit=1").responseJSON()
                            if let value = response.result.value {
                                let json = JSON(value)
                                
                                guard let artistid = json["tracks"]["items"][0]["artists"][0]["id"].string else { continue }
                                if !artistids.contains(artistid) { artistids.append(artistid) }
                            }
                        }
                        
                        //get related artists
                        for i in 0..<3 {
                            var relatedartists = [(id: String, popularity: Int)]()
                            let response = Alamofire.request(.GET, "https://api.spotify.com/v1/artists/" + artistids[i] + "/related-artists").responseJSON()
                            if let value = response.result.value {
                                let json = JSON(value)
                                
                                for artist in json["artists"].array ?? [] {
                                    guard let id = artist["id"].string, popularity = artist["popularity"].int else { continue }
                                    relatedartists.append((id, popularity))
                                }
                                
                                relatedartists.sortInPlace({ $0.popularity > $1.popularity })
                                relatedartists.removeRange(4..<relatedartists.count)
                                artistids += relatedartists.map({ $0.id })
                                artistids = Array(Set(artistids))
                            }
                            
                        }
                        
                        //get top tracks for each artist
                        var magic = [(song: String, artist: String, artwork: String, id: String, popularity: Int)]()
                        
                        for artistid in artistids {
                            let response = Alamofire.request(.GET, "https://api.spotify.com/v1/artists/" + artistid + "/top-tracks?country=US").responseJSON()
                            if let value = response.result.value {
                                let json = JSON(value)
                                
                                for song in json["tracks"].array ?? [] {
                                    let name = song["name"].string ?? ""
                                    let artist = song["artists"][0]["name"].string ?? ""
                                    let popularity = song["popularity"].int ?? 0
                                    let artwork = song["album"]["images"][0]["url"].string ?? ""
                                    var id = ""
                                    
                                    if usingapplemusic {
                                        let response = Alamofire.request(.GET, "https://itunes.apple.com/search?term=" + self.plus(name) + "+" + self.plus(artist) + "&entity=song&isStreamable=true&country=us").responseJSON()
                                        if let value = response.result.value {
                                            let json = JSON(value)
                                            
                                            
                                            id = json["results"][0]["trackId"].intValue.description
                                            
                                            if id == "0" { print("https://itunes.apple.com/search?term=" + self.plus(name) + "+" + self.plus(artist) + "&entity=song&isStreamable=true&country=us") }
                                        }
                                    } else {
                                        id = song["uri"].string ?? ""
                                    }
                                    
                                    magic.append((name, artist, artwork, id, popularity))
                                }
                            }
                        }
                        
                        //remove duplicates?
                        
                        //remove songs already played
                        magic = magic.filter({
                            let range = songlist.count < 30 ? 0..<songlist.count : songlist.count - 30..<songlist.count
                            for song in songlist[range] {
                                if song.song.lowercaseString == $0.song.lowercaseString && song.artist.lowercaseString == $0.artist.lowercaseString {
                                    return false
                                }
                            }
                            
                            return true
                        })
                        
                        //sort by popularity
                        magic.sortInPlace({ $0.popularity > $1.popularity })
                        
                        //prepare library
                        self.magic.removeAll()
                        
                        for song in magic {
                            var newsong = [String : AnyObject]()
                            
                            newsong["name"] = song.song
                            newsong["artist"] = song.artist
                            newsong["mpid"] = ""
                            newsong["amid"] = ""
                            newsong["spid"] = ""
                            newsong["ytid"] = ""
                            newsong["scid"] = ""
                            newsong["votes"] = 0
                            newsong["played"] = false
                            newsong["radio"] = true
                            
                            if usingapplemusic {
                                newsong["amid"] = song.id
                                print("using apple music:", song.song, song.id)
                            } else {
                                newsong["spid"] = song.id
                            }
                            
                            self.magic.append((newsong, song.artwork, false))
                        }
                        
                        //print(self.magic)
                        Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: self.magic[0].song, encoding: .JSON).responseJSON { response in
                            self.fetch()
                            self.magic[0].played = true
                        }
                        
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func getLibrary(handler: () -> ()) {
        print("empty fetching library")
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    //print("JSON: \(json)")
                    
                    var newsong = [String : AnyObject]()
                    
                    for song in json["library"].arrayValue {
                        newsong["name"] = song["name"].string ?? ""
                        newsong["artist"] = song["artist"].string ?? ""
                        newsong["mpid"] = song["mpid"].string ?? ""
                        newsong["amid"] = ""
                        newsong["spid"] = ""
                        newsong["ytid"] = ""
                        newsong["scid"] = ""
                        newsong["votes"] = 0
                        newsong["played"] = false
                        newsong["radio"] = true
                        
                        self.library.append((newsong, false))
                    }
                    
                    handler()
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
}

class SpotifyManager: NSObject, SPTAudioStreamingPlaybackDelegate {
    
    //MARK: - Spotify Player Stack
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        print("did stop playing:", trackUri)
        //if trackUri == PlayerManager.sharedInstance().spid {
        PlayerManager.sharedInstance().fetch()
        //}
    }
    
    func audioStreamingDidBecomeInactivePlaybackDevice(audioStreaming: SPTAudioStreamingController!) {
        print("spotify did become inactive")
        PlayerManager.sharedInstance().fetch()
    }
    
}