//
//  PlayerViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/20/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import SDWebImage
import SVGPlayButton

//var tracktype: tracktypes = .isinactive


class PlayerViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    var metadata: (song: String, artist: String, album: String, artwork: String?, time: Double) {
        get {
            return currentsong
        } set {
            fetch()
        }
    }
    
    /*static var tracktype = tracktypes.isinactive {
        didSet {
            if tracktype == .isinactive {
                if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    // topController should now be your topmost view controller
                    if topController is PlayerViewController {
                        (topController as! PlayerViewController).empty()
                    }
                }
            }
        }
    }
    static var toggle = false
    static var library = [(song: [String : AnyObject], played: Bool)]()
    static var songwatcher: Int = -1 {
        didSet {
            print("songwatcher:", songwatcher)
            if songwatcher == 0 {
                print("song has ended")
                if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    // topController should now be your topmost view controller
                    if topController is PlayerViewController {
                        //switcher = false
                        (topController as! PlayerViewController).fetch()
                    }
                }
            }
        }
    }
    
    let system = MPMusicPlayerController.systemMusicPlayer()
    let video = XCDYouTubeVideoPlayerViewController()
    var videostate: MPMoviePlaybackState = .Stopped {
        didSet {
            fetch()
        }
    }
    
    static var spot = SPTAudioStreamingController(clientId: kClientId)

    var ytid = String()
    var mpid = String()
    var spid = String()
    var amid = String()
    var scid = String()
    var picurl = String()
    //static var switcher = true*/
    
    let video = XCDYouTubeVideoPlayerViewController()
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var player: UIView!
    @IBOutlet weak var playbutton: SVGPlayButton!
    
    @IBOutlet weak var songlabel: UILabel!
    @IBOutlet weak var artistlabel: UILabel!
    @IBOutlet weak var albumlabel: UILabel!
    
    @IBOutlet weak var videobutton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        fetch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playbutton.willPlay = { self.play() }
        playbutton.willPause = { self.pause() }
        
        //addObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>, options: <#T##NSKeyValueObservingOptions#>, context: <#T##UnsafeMutablePointer<Void>#>)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        if PlayerManager.sharedInstance().tracktype == .isyoutube {
            currentsong.time = video.moviePlayer.currentPlaybackTime
        }
        
    }
    
    func fetch() {
        songlabel.text = metadata.song
        artistlabel.text = metadata.artist
        albumlabel.text = metadata.album
        
        if metadata.artwork != nil {image.sd_setImageWithURL(NSURL(string: metadata.artwork!))} else {image.image = UIImage(named: "genericart.png")}
        
        if PlayerManager.sharedInstance().tracktype == .isyoutube {
            videobutton.title = "Show Video"
            videobutton.enabled = true
            video.moviePlayer.currentPlaybackTime = metadata.time
        } else {
            videobutton.title = ""
            videobutton.enabled = false
            image.hidden = false
            player.hidden = true
        }
        
        if PlayerManager.sharedInstance().tracktype == .isinactive {
            playbutton.playing = false
        } else {
            playbutton.playing = true
        }
    }
    
    func ytprepare(ytid: String) {
        video.moviePlayer.fullscreen = false
        video.videoIdentifier = ytid
        video.presentInView(player)
        video.moviePlayer.currentPlaybackTime = currentsong.time
        video.moviePlayer.prepareToPlay()
        video.moviePlayer.play()
    }
    
    /*func fetch() {
        print("fetching")
        system.endGeneratingPlaybackNotifications()
        system.stop()
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
        session.dataTaskWithURL(NSURL(string: "https://clique2016.herokuapp.com/playlists/" + currentclique.id)!, completionHandler: {[unowned self] (data, response, error) in
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
                
                if item["name"].string == "~terminate" {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.image.image = UIImage(named: "genericart.png")
                        self.songlabel.text = ""
                        self.artistlabel.text = ""
                        self.albumlabel.text = ""
                        self.videobutton.title = ""
                    })
                    
                    return
                }
                
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
                PlayerViewController.tracktype = .isyoutube
                print("isyoutube")
            } else if self.mpid != "" {
                PlayerViewController.tracktype = .islocal
                print("islocal")
            } else if self.amid != "" {
                PlayerViewController.tracktype = .isapplemusic
                print("isapplemusic")
            } else if self.spid != "" {
                PlayerViewController.tracktype = .isspotify
                print("isspotify")
            } else if self.scid != "" {
                PlayerViewController.tracktype = .issoundcloud
                print("issoundcloud")
            } else {
                PlayerViewController.tracktype = .isinactive
                print("isinactive")
                currentsong = ("", "", "", "", 0)
                
                let parameters = [
                    "song": "",
                    "artist": ""
                ]
                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/changeSong", parameters: parameters, encoding: .JSON)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.songlabel.text = ""
                    self.artistlabel.text = ""
                    self.albumlabel.text = ""
                    self.image.image = UIImage(named: "genericart.png")
                    self.videobutton.title = ""
                    self.videobutton.enabled = false
                    self.player.hidden = true
                })
                
                nowplaying = false
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
                
                result = result.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
                return result
            }
            
            plussong = plus(song)
            plusartist = plus(artist)
            
            dispatch_async(dispatch_get_main_queue(), {
                if PlayerViewController.tracktype == .isyoutube {
                    self.videobutton.title = "Show Video"
                    self.videobutton.enabled = true
                } else {
                    self.videobutton.title = ""
                    self.videobutton.enabled = false
                    self.image.hidden = false
                    self.player.hidden = true
                }
                
                self.spotifetch(plussong, plusartist: plusartist, usersong: song, userartist: artist)
            })
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
            
            var song = String?()
            var artist = String?()
            var album = String?()
            var cover = String?()
            
            song = json["tracks"]["items"][0]["name"].string
            artist = json["tracks"]["items"][0]["artists"][0]["name"].string
            album = json["tracks"]["items"][0]["album"]["name"].string
            cover = json["tracks"]["items"][0]["album"]["images"][0]["url"].string
            
            dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                if song != nil {self.songlabel.text = song} else {self.songlabel.text = usersong}
                if artist != nil {self.artistlabel.text = artist} else {self.artistlabel.text = userartist}
                if album != nil {self.albumlabel.text = album} else {self.albumlabel.text = ""}
                
                if cover != nil {self.image.sd_setImageWithURL(NSURL(string: cover!))} else {self.image.image = UIImage(named: "genericart.png")}
                
                currentsong = (self.songlabel.text!, self.artistlabel.text!, self.albumlabel.text!, cover, 0)//currentsong.time)
                print(self.ytid)
                
                self.prepare()
            })
            
        }).resume()
    }
    
    func prepare() {
        //step 3: prepare the proper player - may need work
        switch PlayerViewController.tracktype {
        case .isyoutube:
            print("preparing youtube player")
            video.moviePlayer.fullscreen = false
            video.videoIdentifier = ytid
            video.presentInView(player)
            video.moviePlayer.currentPlaybackTime = currentsong.time
            video.moviePlayer.prepareToPlay()
            video.moviePlayer.play()
        case .isspotify:
            print("preparing spotify player")
            PlayerViewController.spot.stop(nil)
            if PlayerViewController.spot.loggedIn {
                PlayerViewController.spot.playURI(NSURL(string: self.spid), callback: nil)
            } else {
                PlayerViewController.spot.loginWithSession(spotifysession, callback: { (error) -> Void in
                    if (error != nil) {
                        print("*** Enabling playback got error: \(error)")
                        return
                    } else {
                        print("PlayerViewController prepare(): spid = " + self.spid)
                        PlayerViewController.spot.playURI(NSURL(string: self.spid), callback: nil)
                    }
                })
            }
        case .islocal:
            print("preparing system player")
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
            return
        }
        
        //update nowplayinginfocenter
        
        nowplaying = true
        finishup()
    }
    
    func finishup() {
        print("finishup")
        //PlayerViewController.switcher = true
        PlayerViewController.songwatcher = -1
        
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
        
        //reset gatekeeper
        //PlayerViewController.tracktype = .isinactive
        
        //must wait until song has already started to restart notifications - busy wait
        //while system.playbackState != .Playing {}
        system.beginGeneratingPlaybackNotifications()
    }
    
    func empty() {
        switch emptydirective {
        case .nothing:
            return
        case .library:
            print("empty directive: selecting song from library")
            if PlayerViewController.library.isEmpty {
                return
            }
            
            var random = Int(arc4random_uniform(UInt32(PlayerViewController.library.count)))
            
            var counter = 0
            while PlayerViewController.library[random].played {
                random = Int(arc4random_uniform(UInt32(PlayerViewController.library.count)))
                counter += 1
                if counter >= PlayerViewController.library.count {
                    for i in 0..<PlayerViewController.library.count {
                        PlayerViewController.library[i].played = false
                    }
                }
            }
            print("empty has selected:", PlayerViewController.library[random])
            let newsong = PlayerViewController.library[random].song
            PlayerViewController.library[random].played = true
            
            Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: newsong, encoding: .JSON).responseJSON { [unowned self] response in
                self.fetch()
            }
        case .magic:
            break
            //use the clique's currentsong field (or maybe even the local currentsong field) to make magic
            //pod "SwiftJavascriptBridge"
            
            //bridge.bridgeLoadScriptFromURL("https://raw.githubusercontent.com/loverajoel/magicplaylist/master/app/js/core/Magic.js")
            
            
        }
    }
    
    
    
    /*static func playerChanged() {
        if !switcher {
            //return
        }
        
        switch tracktype {
        case .isyoutube: return
        case .islocal, .isapplemusic where MPMusicPlayerController.systemMusicPlayer().playbackState != .Stopped: return
        default: PlayerViewController.songwatcher = 0 ; print("playerChanged: attempting to trigger songwatcher didSet")
        }
    }*/
    
    func audioStreamingDidBecomeInactivePlaybackDevice(audioStreaming: SPTAudioStreamingController!) {
        //fetch()
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        if trackUri == spid {
            //PlayerViewController.playerChanged()
            //fetch()
        }
        //spot = SPTAudioStreamingController(clientId: kClientId)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if !isPlaying {
            fetch()
        }
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func videoButton(sender: AnyObject) {
        if videobutton.title == "Show Video" {
            player.hidden = false
            videobutton.title = "Hide Video"
        } else if videobutton.title == "Hide Video" {
            player.hidden = true
            videobutton.title = "Show Video"
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        if PlayerManager.sharedInstance().tracktype == .isyoutube {
            let warning = UIAlertController(title: "Warning", message: "Leaving the Player while a YouTube link is playing will stop playback", preferredStyle: .ActionSheet)
            warning.addAction(UIAlertAction(title: "Leave Anyways", style: UIAlertActionStyle.Destructive, handler: {action in self.dismissViewControllerAnimated(true, completion: nil)}))
            warning.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: {action in }))
            self.showViewController(warning, sender: self)
            
            return
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func rewind(sender: AnyObject) {
        switch PlayerManager.sharedInstance().tracktype {
        case .islocal, .isapplemusic: PlayerManager.sharedInstance().system.currentPlaybackTime = 0
        case .isspotify: PlayerManager.sharedInstance().spot.seekToOffset(0, callback: nil)
        case .isyoutube: video.moviePlayer.currentPlaybackTime = 0
        case .issoundcloud: return
        case .isinactive: return
        }
    }
    
    func play() {
        switch PlayerManager.sharedInstance().tracktype {
        case .islocal, .isapplemusic: PlayerManager.sharedInstance().system.play()
        case .isspotify: PlayerManager.sharedInstance().spot.setIsPlaying(true, callback: nil)
        case .isyoutube: video.moviePlayer.play()
        case .issoundcloud: return
        case .isinactive:
            PlayerManager.sharedInstance().fetch()
            playbutton.playing = false
        }
    }
    
    func pause() {
        switch PlayerManager.sharedInstance().tracktype {
        case .islocal, .isapplemusic: PlayerManager.sharedInstance().system.pause()
        case .isspotify: PlayerManager.sharedInstance().spot.setIsPlaying(false, callback: nil)
        case .isyoutube: video.moviePlayer.pause()
        case .issoundcloud: return
        case .isinactive: return
        }
    }
    
    /*@IBAction func playpause(sender: AnyObject) {
        if PlayerViewController.tracktype == .isyoutube {
            if video.moviePlayer.playbackState == .Playing {
                video.moviePlayer.pause()
                playbutton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(PlayerViewController.playpause(_:)))
                //controlbar.setItems([controlbar.items![0], playbutton, controlbar.items![2]], animated: false)
                //controlbar.items?[1] = playbutton
            } else if video.moviePlayer.playbackState == .Paused {
                video.moviePlayer.play()
                playbutton = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(PlayerViewController.playpause(_:)))
                //controlbar.setItems([controlbar.items![0], playbutton, controlbar.items![2]], animated: false)
                //controlbar.items?[1] = playbutton
            }
        } else {
            if spid != "" {
                PlayerViewController.spot.setIsPlaying(!PlayerViewController.spot.isPlaying, callback: nil)
                
                if PlayerViewController.spot.isPlaying {
                    playbutton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(PlayerViewController.playpause(_:)))
                } else {
                    playbutton = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(PlayerViewController.playpause(_:)))
                }
                
                //controlbar.setItems([controlbar.items![0], playbutton, controlbar.items![2]], animated: false)
                //controlbar.items?[1] = playbutton
                return
            }
            if system.playbackState == .Playing {
                system.pause()
                playbutton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(PlayerViewController.playpause(_:)))
                //controlbar.setItems([controlbar.items![0], playbutton, controlbar.items![2]], animated: false)
                //controlbar.items?[1] = playbutton
            } else if system.playbackState == .Paused {
                system.play()
                playbutton = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(PlayerViewController.playpause(_:)))
                //controlbar.setItems([controlbar.items![0], playbutton, controlbar.items![2]], animated: false)
                //controlbar.items?[1] = playbutton
            }
        }
    }*/
    
    @IBAction func fastforward(sender: AnyObject) {
        PlayerManager.sharedInstance().fetch()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
