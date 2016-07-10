//
//  PlayerViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/20/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import SDWebImage
import SVGPlayButton

//var tracktype: tracktypes = .isinactive


class PlayerViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, YTPlayerViewDelegate {
    
    static var youtubewaiting = false
    
    var metadata: (song: String, artist: String, album: String, artwork: String?, time: Double) {
        get {
            return currentsong
        } set {
            fetch()
        }
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var player: YTPlayerView!
    @IBOutlet weak var rewindbutton: UIButton!
    @IBOutlet weak var playbutton: SVGPlayButton!
    @IBOutlet weak var fastforwardbutton: UIButton!
    
    @IBOutlet weak var songlabel: UILabel!
    @IBOutlet weak var artistlabel: UILabel!
    @IBOutlet weak var albumlabel: UILabel!
    
    @IBOutlet weak var videobutton: UIBarButtonItem!
    @IBOutlet weak var bottombar: UIToolbar!
    @IBOutlet weak var savebutton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        fetch()
        
        if PlayerViewController.youtubewaiting && player.playerState() != .Playing {
            ytprepare()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerViewController.fetch), name: "PlayerManagerDidChangeSong", object: nil)
        playbutton.willPlay = { self.play() }
        playbutton.willPause = { self.pause() }
        player.delegate = self
        
        /*waves.idleAmplitude = 0.9
        waves.numberOfWaves = 3
        waves.frequency = 0.6
        waves.density = 0.6
        waves.primaryWaveLineWidth = 0.5
        waves.secondaryWaveLineWidth = 0.2*/
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        PlayerViewController.youtubewaiting = false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        if PlayerManager.sharedInstance().tracktype == .isyoutube {
            currentsong.time = Double(player.currentTime())
        }
        
    }
    
    func fetch() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.songlabel.text = self.metadata.song
            self.artistlabel.text = self.metadata.artist
            self.albumlabel.text = self.metadata.album
        
            if self.metadata.artwork != nil {self.image.sd_setImageWithURL(NSURL(string: self.metadata.artwork!))} else {self.image.image = UIImage(named: "genericart.png")}
        
            self.videobutton.title = ""
            self.videobutton.enabled = false
            self.image.hidden = false
            self.player.hidden = true
        
            if PlayerManager.sharedInstance().tracktype == .isinactive {
                self.playbutton.playing = false
                self.savebutton.enabled = false

            } else {
                self.playbutton.playing = true
                self.savebutton.enabled = true
            }
            
            switch PlayerManager.sharedInstance().tracktype {
            case .islocal:
                if PlayerManager.sharedInstance().autoplaying {
                    self.videobutton.title = "Autoplay"
                } else {
                    self.videobutton.title = "Clique"
                }
                self.bottombar.barTintColor = UIColor.lightGrayColor()
            case .isapplemusic:
                self.videobutton.title = "Apple Music"
                self.bottombar.barTintColor = UIColor(red: 100/255, green: 69/255, blue: 250/255, alpha: 0.75)
            case .isspotify:
                self.videobutton.title = "Spotify"
                self.bottombar.barTintColor = UIColor(red: 25/255, green: 214/255, blue: 72/255, alpha: 0.75)
            case .isyoutube:
                self.videobutton.title = "Show Video"
                self.bottombar.barTintColor = UIColor(red: 208/255, green: 10/255, blue: 20/255, alpha: 0.75)
            
                self.videobutton.enabled = true
                self.ytprepare()
            case .issoundcloud:
                self.videobutton.title = "Soundcloud"
                self.bottombar.barTintColor = UIColor(red: 251/255, green: 113/255, blue: 0/255, alpha: 0.75)
            case .isinactive:
                self.videobutton.title = "Clique"
                self.bottombar.barTintColor = UIColor.lightGrayColor()
            }
        })
        
        rewindbutton.enabled = true
        //rewindbutton.tintColor = view.window?.tintColor
        playbutton.enabled = true
        //playbutton.tintColor = view.window?.tintColor
        fastforwardbutton.enabled = true
        //fastforwardbutton.tintColor = view.window?.tintColor
    }
    
    func ytprepare() {
        player.loadWithVideoId(PlayerManager.sharedInstance().ytid, playerVars: ["playsinline": 1, "autohide": 1, "autoplay": 1, "rel": 0, "showinfo": 0, "modestbranding": 1])
        player.seekToSeconds(Float(metadata.time), allowSeekAhead: true)

        videoButton(UIView())
        player.playVideo()
        PlayerViewController.youtubewaiting = false
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        //let scale = newWidth / image.size.width
        //let newHeight = image.size.height * scale
        let newHeight = newWidth
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
        if state == .Ended {
            playbutton.playing = false
            PlayerManager.sharedInstance().fetch()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func videoButton(sender: AnyObject) {
        if PlayerManager.sharedInstance().tracktype != .isyoutube {
            return
        }
        
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
        case .isyoutube: player.seekToSeconds(0, allowSeekAhead: true)
        case .issoundcloud: return
        case .isinactive: return
        }
    }
    
    func play() {
        switch PlayerManager.sharedInstance().tracktype {
        case .islocal, .isapplemusic: PlayerManager.sharedInstance().system.play()
        case .isspotify: PlayerManager.sharedInstance().spot.setIsPlaying(true, callback: nil)
        case .isyoutube: player.playVideo()
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
        case .isyoutube: player.pauseVideo()
        case .issoundcloud: return
        case .isinactive: return
        }
    }
    
    @IBAction func fastforward(sender: AnyObject) {
        PlayerManager.sharedInstance().fetch()
        
        rewindbutton.enabled = false
        playbutton.enabled = false
        fastforwardbutton.enabled = false
    }
    
    @IBAction func save(sender: AnyObject) {
        let save = UIAlertController(title: "Add Song to Saved?", message: "Your saved songs can be viewed at any time in Private Listening mode.", preferredStyle: .ActionSheet)
        save.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil))
        save.addAction(UIAlertAction(title: "Save", style: .Default, handler: { action in
            var saves = NSUserDefaults.standardUserDefaults().objectForKey("Saved") as? [[String]] ?? []
            saves.append([self.metadata.song, self.metadata.artist, self.metadata.artwork ?? ""])
            print(saves)
            NSUserDefaults.standardUserDefaults().setObject(saves, forKey: "Saved")
        }))
        
        presentViewController(save, animated: true, completion: nil)
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
