//
//  PlayerManager.swift
//  Clique
//
//  Created by Phil Hawkins on 5/30/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVFoundation
import XCDYouTubeKit
import SwiftyJSON
import Alamofire
import SDWebImage
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
            
            plussong = plus(song)
            plusartist = plus(artist)
            
            
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
            
            let shuffle = {
                var random = Int(arc4random_uniform(UInt32(self.library.count)))
                
                var counter = 0
                while self.library[random].played {
                    random = Int(arc4random_uniform(UInt32(self.library.count)))
                    counter += 1
                    if counter >= self.library.count {
                        for i in 0..<self.library.count {
                            self.library[i].played = false
                        }
                    }
                }
                print("empty has selected:", self.library[random])
                let newsong = self.library[random].song
                self.library[random].played = true
                
                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: newsong, encoding: .JSON).responseJSON { response in
                    self.fetch()
                }
            }
            
            if library.isEmpty {
                getLibrary(completionHandler: shuffle)
            } else {
                shuffle()
            }
            
            
        case .magic:
            break
            //use the clique's currentsong field (or maybe even the local currentsong field) to make magic
            //pod "SwiftJavascriptBridge"
            
            //bridge.bridgeLoadScriptFromURL("https://raw.githubusercontent.com/loverajoel/magicplaylist/master/app/js/core/Magic.js")
            
            
        }
    }
    
    func getLibrary(completionHandler block: ()->()) {
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
                        
                        self.library.append((newsong, false))
                    }
                    
                    block()
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