//
//  HistoryViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 4/13/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var clique = [(song: String, artist: String, artwork: String?, votes: Int, voting_available: Bool)]()
    @IBOutlet weak var table: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = privatelistening ? blue : UIColor.orangeColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if #available(iOS 8.2, *) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
            ]
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
        }
        
        //fetch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.hidden = true
        table.delegate = self
        table.dataSource = self
        
        if false { //!UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = UIColor.clearColor()
            table.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            //self.view.addSubview(blurEffectView)
            table.addSubview(blurEffectView)
            //if you have more UIViews, use an insertSubview API to place it where needed
        } 
        else {
            self.view.backgroundColor = UIColor.whiteColor()
        }
        
        fetch()
    }
    
    func fetch() {
        print("fetching")
        clique.removeAll()
        
        var prime = [(song: String, artist: String, artwork: String?, votes: Int)]()
        var song = ""
        var artist = ""
        var votes = 0
        
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let list = json["songList"].array ?? []
                    
                    for item in list {
                        if !item["played"].boolValue {
                            continue
                        }
                        
                        song = item["name"].string ?? "No Title"
                        artist = item["artist"].string ?? "No Artist"
                        votes = item["votes"].int ?? 0
                        
                        prime.append((song, artist, nil, votes))
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.spotifetch(prime)
                    })
                }
            case .Failure(let error):
                print(error)
            }
        }
        
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
        
        
        //step 2: verify names and find album+artwork - spotify api
        for song in prime {
            if song.song == "~terminate" {
                continue
            }
            
            let plussong = plus(song.song)
            let plusartist = plus(song.artist)
            
            let response = Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=track:" + plussong + "%20artist:" + plusartist + "&type=track&limit=1").responseJSON()
            if let value = response.result.value {
                let json = JSON(value)
                
                var title = String?()
                var artist = String?()
                var cover = String?()
                
                var newentry: (song: String, artist: String, artwork: String?, votes: Int, voting_available: Bool) = ("", "", nil, song.votes, false)
                
                title = json["tracks"]["items"][0]["name"].string
                artist = json["tracks"]["items"][0]["artists"][0]["name"].string
                cover = json["tracks"]["items"][0]["album"]["images"][0]["url"].string
                
                if title != nil {newentry.song = title!} else {newentry.song = song.song}
                if artist != nil {newentry.artist = artist!} else {newentry.artist = song.artist}
                
                if cover != nil {newentry.artwork = cover!}
                
                self.clique.append(newentry)
            }
        }
        
        self.clique = self.clique.reverse()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.table.reloadData()
            self.table.setNeedsDisplay()
            self.table.hidden = false
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clique.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("song")
        
        //if indexPath.section != 0 {
            cell?.textLabel?.text = clique[indexPath.row].song
            cell?.detailTextLabel?.text = clique[indexPath.row].artist
            if clique[indexPath.row].artwork != nil {
                cell?.imageView?.sd_setImageWithURL(NSURL(string: clique[indexPath.row].artwork!), placeholderImage: UIImage(named: "genericart.png")!)
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }
        
        if cell?.imageView?.image != nil {
            let widthScale = 50/(cell?.imageView?.image!.size.width)!
            let heightScale = 50/(cell?.imageView?.image!.size.height)!
            cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
        }
        //}
        
        cell?.backgroundColor = UIColor.clearColor()
        
        return cell!
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let save = UITableViewRowAction(style: .Default, title: "Save", handler: { (action, indexPath) in
            var saves = NSUserDefaults.standardUserDefaults().objectForKey("Saved") as? [[String]] ?? []
            saves.append([self.clique[indexPath.row].song, self.clique[indexPath.row].artist, self.clique[indexPath.row].artwork ?? ""])
            print(saves)
            NSUserDefaults.standardUserDefaults().setObject(saves, forKey: "Saved")
            
            tableView.setEditing(false, animated: true)
        })
        save.backgroundColor = view.window?.tintColor
        
        return [save]
    }
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
