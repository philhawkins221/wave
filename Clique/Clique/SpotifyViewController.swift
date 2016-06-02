//
//  SpotifyViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 5/10/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class SpotifyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var results = [(song: String, artist: String, album: String, spid: String)]()

    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        table.hidden = true
        
        fetch()
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
    
    func fetch() {
        results.removeAll()
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=track:" + plus(searchsong) + "%20artist:" + plus(searchartist) + "&type=track&limit=50").responseJSON {response in
            
            switch response.result {
            case .Success:
                print("spotifyviewcontroller: success")
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    //print(json)
                    
                    for result in json["tracks"]["items"].array ?? [] {
                        let spid = result["uri"].string ?? ""
                        let song = result["name"].string ?? ""
                        let artist = json["tracks"]["items"][0]["artists"][0]["name"].string ?? ""
                        let album = json["tracks"]["items"][0]["album"]["images"][0]["url"].string ?? ""
                        
                        print((song, artist, album, spid))
                        self.results.append((song, artist, album, spid))
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.table.reloadData()
                        self.table.setNeedsDisplay()
                        self.table.hidden = false
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
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item")
        
        if results.isEmpty {
            cell?.textLabel?.text = "No results found"
            cell?.detailTextLabel?.text = "Try again using a different search"
        }
        
        cell?.textLabel?.text = results[indexPath.row].song
        cell?.detailTextLabel?.text = results[indexPath.row].artist
        cell?.imageView?.sd_setImageWithURL(NSURL(string: results[indexPath.row].album))
        
        if cell?.imageView?.image != nil {
            let widthScale = 50/(cell?.imageView?.image!.size.width)!
            let heightScale = 50/(cell?.imageView?.image!.size.height)!
            cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let add = UIAlertController(title: "Add Song", message: "Add this song to clique?", preferredStyle: .Alert)
        add.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: {action in }))
        add.addAction(UIAlertAction(title: "Add", style: .Default, handler: {action in
            var parameters = [String : AnyObject]()
            parameters = [
                "name": searchsong,
                "artist": searchartist,
                "mpid": "",
                "ytid": "",
                "spid": self.results[indexPath.row].spid,
                "amid": "",
                "scid": "",
                "votes": 0,
                "played": false
            ]
            
            Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: parameters as [String : AnyObject], encoding: .JSON)
        }))
        
        self.presentViewController(add, animated: true, completion: nil)
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
