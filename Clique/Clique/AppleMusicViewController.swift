//
//  AppleMusicViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 5/20/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import StoreKit
import MediaPlayer

class AppleMusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var results = [(song: String, artist: String, album: String, amid: String)]()

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
        
        result = result.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? ""
        return result
    }
    
    func fetch() {
        results.removeAll()
        
        Alamofire.request(.GET, "https://itunes.apple.com/search?term=" + plus(searchsong) + "+" + plus(searchartist) + "&entity=song&isStreamable=true&country=us").responseJSON {[unowned self] response in
            
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    for result in json["results"].array ?? [] {
                        let amid = result["trackId"].int?.description ?? ""
                        let song = result["trackName"].string ?? ""
                        let artist = result["artistName"].string ?? ""
                        let album = result["artworkUrl100"].string ?? ""
                        
                        self.results.append((song, artist, album, amid))
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { [unowned self] in
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
        cell?.imageView?.sd_setImageWithURL(NSURL(string: results[indexPath.row].album), placeholderImage: UIImage(named: "genericart.png")!)
        
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
        add.addAction(UIAlertAction(title: "Add", style: .Default, handler: {[unowned self] action in
            var parameters = [String : AnyObject]()
            parameters = [
                "name": self.results[indexPath.row].song,
                "artist": self.results[indexPath.row].artist,
                "mpid": "",
                "ytid": "",
                "amid": self.results[indexPath.row].amid,
                "spid": "",
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
