//
//  DummyPlayerViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 5/29/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class DummyPlayerViewController: UIViewController {
    
    var dummysong: (name: String, artist: String, album: String, artwork: String) = ("", "", "", "")
    var timer = NSTimer()
    
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var artistlabel: UILabel!
    @IBOutlet weak var albumlabel: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        fetch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)

    }
    
    func fetch() {
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { [unowned self] response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dummysong = (json["currentSong"].string ?? "", json["artist"].string ?? "", "", "")
                        
                        if self.dummysong == ("", "", "", "") {
                            self.artwork.image = UIImage(named: "genericart.png")
                            self.titlelabel.text = ""
                            self.artistlabel.text = ""
                            self.albumlabel.text = ""
                            
                            return
                        }
                        
                        self.spotifetch()
                    })
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func spotifetch() {
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
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=track:" + plus(dummysong.name) + "%20artist:" + plus(dummysong.artist) + "&type=track&limit=1").responseJSON { [unowned self] response in
            switch response.result {
            case .Success:
                if let value = response.result.value where self.dummysong.name != "" {
                    let json = JSON(value)
                    
                    self.dummysong.album = json["tracks"]["items"][0]["album"]["name"].string ?? ""
                    self.dummysong.artwork = json["tracks"]["items"][0]["album"]["images"][0]["url"].string ?? ""
                    
                    self.finishup()
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func finishup() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.titlelabel.text = self.dummysong.name
            self.artistlabel.text = self.dummysong.artist
            self.albumlabel.text = self.dummysong.album
            
            self.artwork.sd_setImageWithURL(NSURL(string: self.dummysong.artwork), placeholderImage: UIImage(named: "genericart.png"))
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
