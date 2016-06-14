//
//  AddViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 3/30/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var searchsong = ""
var searchartist = ""

enum bases {
    case youtube
    case spotify
    case soundcloud
    case applemusic
}

//TODO: consider url encoding songs before adding them to the queue - may cause less dead plays

class AddViewController: UIViewController {
    
    var base = bases.youtube

    @IBOutlet weak var songbar: UITextField!
    @IBOutlet weak var artistbar: UITextField!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var librarybutton: UIButton!
    @IBOutlet weak var applemusicbutton: UIButton!
    @IBOutlet weak var spotifybutton: UIButton!
    @IBOutlet weak var youtubebutton: UIButton!
    @IBOutlet weak var soundcloudbutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fetch()
    }
    
    func fetch() {
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if json["spotify"].bool ?? false {
                            currentclique.spotify = true
                        } else {
                            currentclique.spotify = false
                        }
                        
                        if json["applemusic"].bool ?? false {
                            currentclique.applemusic = true
                        } else {
                            currentclique.applemusic = false
                        }
                    })
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func applemusicpressed(sender: AnyObject) {
        if !currentclique.applemusic {
            let nope = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            nope.title = "Apple Music Not Available"
            
            if currentclique.leader {
                nope.message = "To select from Apple Music you must enable Apple Music in the Clique settings."
            } else {
                nope.message = "To select from Apple Music, the leader of this Clique must enable Apple Music in the Clique settings"
            }
            
            nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(nope, animated: true, completion: nil)
            
            return
        }
        base = .applemusic
        cleartheair()
    }
    
    @IBAction func ytpressed(sender: AnyObject) {
        base = .youtube
        cleartheair()
    }
    
    @IBAction func spotifypressed(sender: AnyObject) {
        if !currentclique.spotify {
            let nope = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            nope.title = "Spotify Not Available"
            
            if currentclique.leader {
                nope.message = "To select from Spotify you must enable Spotify in the Clique settings."
            } else {
                nope.message = "To select from Spotify, the leader of this Clique must enable Spotify in the Clique settings."
            }
            
            nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(nope, animated: true, completion: nil)
            
            return
        }
        
        base = .spotify
        cleartheair()
    }
    
    @IBAction func soundcloudpressed(sender: AnyObject) {
        //testing purposes only
        soundcloudbutton.setTitle("Coming Soon!", forState: .Normal)
        soundcloudbutton.alpha = 0.25
        soundcloudbutton.enabled = false
        return Void()
        
        base = .soundcloud
        cleartheair()
    }
    
    func cleartheair() {
        switch base {
        case .applemusic:
            title = "Select from Apple Music"
        case .spotify:
            title = "Select from Spotify"
        case .youtube:
            title = "Select from YouTube"
        case .soundcloud:
            title = "Select from Soundcloud"
        }
        
        librarybutton.hidden = true
        applemusicbutton.hidden = true
        spotifybutton.hidden = true
        youtubebutton.hidden = true
        soundcloudbutton.hidden = true
        
        songbar.hidden = false
        artistbar.hidden = false
        search.hidden = false
        
        UIView.animateWithDuration(0.75, animations: { [unowned self] in
            self.songbar.alpha = 1
            self.artistbar.alpha = 1
            self.search.alpha = 1
        })
        
        songbar.becomeFirstResponder()

    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        searchsong = songbar.text ?? ""
        searchartist = artistbar.text ?? ""
        
        switch base {
        case .applemusic:
            let am = storyboard?.instantiateViewControllerWithIdentifier("applemusic")
            showViewController(am!, sender: self)
        case .spotify:
            let spotify = storyboard?.instantiateViewControllerWithIdentifier("spotify")
            showViewController(spotify!, sender: self)
        case .soundcloud:
            let sc = storyboard?.instantiateViewControllerWithIdentifier("soundcloud")
            showViewController(sc!, sender: self)
        case .youtube:
            let yt = storyboard?.instantiateViewControllerWithIdentifier("yt")
            showViewController(yt!, sender: self)
        }
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
