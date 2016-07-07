//
//  CliqueViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/19/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import SwiftyJSON
import MediaPlayer
import Alamofire

var currentclique: (id: String, leader: Bool, name: String, passcode: String, applemusic: Bool, spotify: Bool, voting: Bool) = ("", false, "", "", false, false, true)

class CliqueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var clique = [(song: String, artist: String, artwork: String?, votes: Int, voting_available: Bool)]()
    //var library = [(song: String, artist: String)]()
    var currentSong: (name: String, artist: String, artwork: String) = ("", "", "") {
        didSet {
            table.reloadData()
        }
    }
    var timer = NSTimer()

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var player: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        table.hidden = true
        
//        if currentclique.leader {
//            player.enabled = true
//        } else {
//            player.enabled = false
//        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        clique.removeAll()
        fetch()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
        
        if let selected = table.indexPathForSelectedRow {
            table.deselectRowAtIndexPath(selected, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        timer.invalidate()
    }
    
    func fetch() {
        print("fetching")
        clique.removeAll()
        
        //TODO: check "voting" status in clique
        
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.currentSong = (json["currentSong"].string ?? "", json["artist"].string ?? "", "")
                    })
                }
            case .Failure(let error):
                print(error)
            }
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var prime = [(song: String, artist: String, artwork: String?, votes: Int)]()
        var song = ""
        var artist = ""
        var votes = 0
        
        //step 1: pull the next song - get the stored artist and song name
        session.dataTaskWithURL(NSURL(string: "https://clique2016.herokuapp.com/playlists/" + currentclique.id)!, completionHandler: {(data, response, error) in
            if data == nil {
                print("no data")
                return
            }
            let json = JSON(data: data!)
            dispatch_async(dispatch_get_main_queue(), { self.title = json["name"].stringValue })
            
            let list = json["songList"].array ?? []
            
            for item in list {
                if item["played"].boolValue {
                    continue
                }
                
                song = item["name"].string ?? "No Title"
                artist = item["artist"].string ?? "No Artist"
                votes = item["votes"].int ?? 0
                
                prime.append((song, artist, nil, votes))
            }
            
            //check if the fetch came back empty
            if song == "" && artist == "" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.table.hidden = false
                })
                
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.spotifetch(prime)
            })
        }).resume()
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
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        //step 2: verify names and find album+artwork - spotify api
        for song in prime {

            let plussong = plus(song.song)
            let plusartist = plus(song.artist)
            
            session.dataTaskWithURL(NSURL(string: "https://api.spotify.com/v1/search?q=track:" + plussong + "%20artist:" + plusartist + "&type=track&limit=1")!, completionHandler: {(data, response, error) in
                if data == nil {
                    print("no data")
                    return
                }
                let json = JSON(data: data!)
            
                var title = String?()
                var artist = String?()
                var cover = String?()
            
                var newentry: (song: String, artist: String, artwork: String?, votes: Int, voting_available: Bool) = ("", "", nil, song.votes, true)
            
                title = json["tracks"]["items"][0]["name"].string
                artist = json["tracks"]["items"][0]["artists"][0]["name"].string
                cover = json["tracks"]["items"][0]["album"]["images"][0]["url"].string
            
                if title != nil {newentry.song = title!} else {newentry.song = song.song}
                if artist != nil {newentry.artist = artist!} else {newentry.artist = song.artist}
            
                if cover != nil {newentry.artwork = cover!}
                
                self.clique.append(newentry)
            
                dispatch_async(dispatch_get_main_queue(), {
                    self.table.reloadData()
                    self.table.setNeedsDisplay()
                    self.table.hidden = false
                })
            }).resume()
            
            Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=track:" + plus(currentSong.name) + "%20artist:" + plus(currentSong.artist) + "&type=track&limit=1").responseJSON { [unowned self] response in
                switch response.result {
                case .Success:
                    if let value = response.result.value where self.currentSong.name != "" {
                        let json = JSON(value)
                        
                        self.currentSong.artwork = json["tracks"]["items"][0]["album"]["images"][0]["url"].string ?? ""
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return clique.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return 60
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CliqueSongTableViewCell?
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("nowplaying") as? CliqueSongTableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("song") as? CliqueSongTableViewCell
        }
        
        if indexPath.section != 0 {
            
            if clique.isEmpty {
                cell?.textLabel?.text = "Clique is Empty"
                cell?.detailTextLabel?.text = "Press the add button below to start listening"
                cell?.voteslabel.text = ""
                
                return cell!
            }
            
            cell?.textLabel?.text = clique[indexPath.row].song
            cell?.detailTextLabel?.text = clique[indexPath.row].artist
            cell?.voteslabel.text = clique[indexPath.row].votes.description
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
        } else { //TODO: - get current song, maybe do this in fetch()
            cell?.textLabel?.text = currentSong.name
            cell?.detailTextLabel?.text = currentSong.artist
            cell?.imageView?.sd_setImageWithURL(NSURL(string: currentSong.artwork), placeholderImage: UIImage(named: "genericart.png")!)
            //cell?.backgroundColor = UIColor.lightTextColor()

            if cell?.imageView?.image != nil {
                let widthScale = 100/(cell?.imageView?.image!.size.width)!
                let heightScale = 100/(cell?.imageView?.image!.size.height)!
                cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
            }
        }
        
        if indexPath.section == 1 {
            cell?.accessoryType = .None
        } else {
            cell?.accessoryType = .DisclosureIndicator
        }
        
        if privatelistening {
            cell?.voteslabel.text = ""
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            showPlayer(UIView())
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Now Playing"
        } else if section == 1 {
            return "Up Next"
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 || privatelistening {
            return nil
        }
        
        let upvote = UITableViewRowAction(style: .Default, title: "+", handler: {(action, indexpath) in
            if self.clique[indexPath.row].voting_available {
                let p = [
                    "name": self.clique[indexPath.row].song,
                    "artist": self.clique[indexPath.row].artist
                ]
                
                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/upvote", parameters: p, encoding: .JSON)
                
                self.clique[indexPath.row].voting_available = false
                self.clique[indexPath.row].votes += 1
                self.table.setEditing(false, animated: false)
                self.table.reloadData()
            }
        })
        
        let downvote = UITableViewRowAction(style: .Default, title: "-", handler: {(action, indexpath) in
            if self.clique[indexPath.row].voting_available {
                let p = [
                    "name": self.clique[indexPath.row].song,
                    "artist": self.clique[indexPath.row].artist
                ]
                
                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/downvote", parameters: p, encoding: .JSON)
                
                self.clique[indexPath.row].voting_available = false
                self.clique[indexPath.row].votes -= 1
                self.table.setEditing(false, animated: true)
                self.table.reloadData()
            }
        })
        
        let votes = UITableViewRowAction(style: .Default, title: clique[indexPath.row].votes.description, handler: {(action, indexpath) in })
        
        upvote.backgroundColor = UIColor(red: 0, green: 147/255, blue: 0, alpha: 1)
        votes.backgroundColor = UIColor.grayColor()
        downvote.backgroundColor = UIColor.redColor()
        
        return [upvote, downvote]
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        if #available(iOS 8.2, *) {
            title.font = UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
        } else {
            // Fallback on earlier versions
        }
        title.textColor = UIColor.whiteColor()
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font=title.font
        header.textLabel?.textColor=title.textColor
        header.contentView.backgroundColor = UIColor.lightGrayColor()
    }
    
    // MARK: - IBActions
    
    @IBAction func addTouched(sender: AnyObject) {
        let add = storyboard?.instantiateViewControllerWithIdentifier("add")
        showViewController(add!, sender: self)
        //presentViewController(add!, animated: true, completion: nil)
    }
    
    @IBAction func showPlayer(sender: AnyObject) {
        if currentclique.leader {
            let player = storyboard?.instantiateViewControllerWithIdentifier("player")
            presentViewController(player!, animated: true, completion: nil)
        } else {
            let dummy = storyboard?.instantiateViewControllerWithIdentifier("dummy")
            presentViewController(dummy!, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButton(sender: AnyObject) {
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
