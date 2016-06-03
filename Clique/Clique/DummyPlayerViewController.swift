//
//  DummyPlayerViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 5/29/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit

class DummyPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    func fetch() {
//        //needs to get most info in metadata
//        //also needs to get type
//    }
//    
//    func prepare() {
//        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
//            self.songlabel.text = self.metadata.song
//            self.artistlabel.text = self.metadata.artist
//            self.albumlabel.text = self.metadata.album
//            
//            if self.metadata.artwork != nil {self.image.sd_setImageWithURL(NSURL(string: self.metadata.artwork!))} else {self.image.image = UIImage(named: "genericart.png")}
//            
//            self.videobutton.title = ""
//            self.videobutton.enabled = false
//            self.image.hidden = false
//            self.player.hidden = true
//            
//            if PlayerManager.sharedInstance().tracktype == .isinactive {
//                self.playbutton.playing = false
//            } else {
//                self.playbutton.playing = true
//            }
//            
//            switch PlayerManager.sharedInstance().tracktype {
//            case .islocal:
//                if PlayerManager.sharedInstance().autoplaying {
//                    self.videobutton.title = "Autoplay"
//                } else {
//                    self.videobutton.title = ""
//                }
//                self.bottombar.barTintColor = UIColor.lightGrayColor()
//            case .isapplemusic:
//                self.videobutton.title = "Apple Music"
//                self.bottombar.barTintColor = UIColor(red: 100/255, green: 69/255, blue: 250/255, alpha: 0.75)
//            case .isspotify:
//                self.videobutton.title = "Spotify"
//                self.bottombar.barTintColor = UIColor(red: 25/255, green: 214/255, blue: 72/255, alpha: 0.75)
//            case .isyoutube:
//                self.videobutton.title = "Show Video"
//                self.bottombar.barTintColor = UIColor(red: 208/255, green: 10/255, blue: 20/255, alpha: 0.75)
//                
//                self.videobutton.enabled = true
//                self.ytprepare()
//            case .issoundcloud:
//                self.videobutton.title = "Soundcloud"
//                self.bottombar.barTintColor = UIColor(red: 251/255, green: 113/255, blue: 0/255, alpha: 0.75)
//            case .isinactive:
//                self.videobutton.title = ""
//                self.bottombar.barTintColor = UIColor.whiteColor()
//            }
//        })
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
