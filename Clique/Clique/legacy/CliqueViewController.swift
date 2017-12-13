//
//  CliqueViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/19/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class CliqueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var currentSong: (name: String, artist: String, artwork: String) = ("", "", "")
    var timer = NSTimer()
    var vclibrary = [(song: [String : AnyObject], played: Bool)]()
    var magic = [(song: [String : AnyObject], artwork: String, played: Bool)]()

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var player: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        //table.hidden = true
        
        if currentclique.leader {
            table.setEditing(true, animated: true)
            
            if emptydirective == .nothing && (currentclique.applemusic || currentclique.spotify) {
                emptydirective = .magic
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.title = currentclique.name
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refresh), name: "CliqueUpdated", object: nil)

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
        //recheck voting status
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if currentclique.voting != json["voting"].boolValue {
                        currentclique.voting = !currentclique.voting
                    }
                }
            case .Failure(let error):
                print(error)
                
                if error.code == -6006 {
                    let alert = UIAlertController(title: "Clique Disbanded", message: "This Clique no longer exists.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Go Back", style: .Cancel) { action in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        
        //fetch current song
        let r1 = Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON()
        if let value = r1.result.value {
            let json = JSON(value)
            
            self.currentSong = (json["currentSong"].string ?? "", json["artist"].string ?? "", "")
        }
        
        //get artwork for current song
        let r2 = Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=track:" + PlayerManager.sharedInstance().plus(currentSong.name) + "%20artist:" + PlayerManager.sharedInstance().plus(currentSong.artist) + "&type=track&limit=1").responseJSON()
        if let value = r2.result.value, self.currentSong.name != "" {
            let json = JSON(value)
            
            self.currentSong.artwork = json["tracks"]["items"][0]["album"]["images"][0]["url"].string ?? ""
        }
        
        //fetch up next
        CliqueManager.sharedInstance().fetch()
        
        //update libraries
        vclibrary = PlayerManager.sharedInstance().library.filter({ !$0.played })
        magic = PlayerManager.sharedInstance().magic.filter({ !$0.played })
        
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), {
            self.table.reloadData()
            self.table.hidden = false
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - TableView Stack

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch emptydirective {
        case .library, .magic where currentclique.leader: return 3
        default: return 2
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return CliqueManager.sharedInstance().clique.isEmpty ? 1 : CliqueManager.sharedInstance().clique.count
        case 2: return emptydirective == .library ? vclibrary.count : magic.count
        default: return 0
        }
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
            cell = tableView.dequeueReusableCellWithIdentifier("song") as CliqueSongTableViewCell
        }

        if indexPath.section != 0 {
            
            if indexPath.section == 2 {
                switch emptydirective {
                case .library:
                    let song = vclibrary[indexPath.row].song
                    
                    cell?.textLabel?.text = song["name"] as? String ?? ""
                    cell?.detailTextLabel?.text = song["artist"] as? String ?? ""
                    cell?.imageView?.image = nil
                    cell?.voteslabel.text = ""
                case .magic:
                    let song = magic[indexPath.row]
                    
                    cell?.textLabel?.text = song.song["name"] as? String ?? ""
                    cell?.detailTextLabel?.text = song.song["artist"] as? String ?? ""
                    cell?.imageView?.sd_setImageWithURL(NSURL(string: song.artwork), placeholderImage: UIImage(named: "genericart.png")!)
                    cell?.voteslabel.text = ""
                    
                    if cell?.imageView?.image != nil {
                        let widthScale = 50/(cell?.imageView?.image!.size.width)!
                        let heightScale = 50/(cell?.imageView?.image!.size.height)!
                        cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
                    }
                default: break
                }
                
                return cell!
            }
            
            if CliqueManager.sharedInstance().clique.isEmpty {
                cell?.textLabel?.text = "Clique is Empty"
                cell?.detailTextLabel?.text = "Press the add button below to start listening"
                cell?.voteslabel.text = ""
                cell?.imageView?.image = nil

                return cell!
            }

            cell?.textLabel?.text = CliqueManager.sharedInstance().clique[indexPath.row].song
            cell?.detailTextLabel?.text = CliqueManager.sharedInstance().clique[indexPath.row].artist
            cell?.voteslabel.text = CliqueManager.sharedInstance().clique[indexPath.row].votes.description
            if CliqueManager.sharedInstance().clique[indexPath.row].artwork != nil {
                cell?.imageView?.sd_setImageWithURL(NSURL(string: CliqueManager.sharedInstance().clique[indexPath.row].artwork!), placeholderImage: UIImage(named: "genericart.png")!)
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }

            if cell?.imageView?.image != nil {
                let widthScale = 50/(cell?.imageView?.image!.size.width)!
                let heightScale = 50/(cell?.imageView?.image!.size.height)!
                cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
            }
        } else {
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

        if indexPath.section == 0 {
            cell?.accessoryType = .DisclosureIndicator
        } else {
            cell?.accessoryType = .None
        }

        if privatelistening || !currentclique.voting {
            cell?.voteslabel?.text = ""
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
        } else if section == 2 {
            return emptydirective == .library ? "From Clique Music Library" : "Clique Radio"
        }

        return nil
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 || indexPath.section == 2 {
            return nil
        }

        let upvote = UITableViewRowAction(style: .Default, title: "+", handler: {(action, indexpath) in
            if CliqueManager.sharedInstance().clique[indexPath.row].voting_available {
                let p = [
                    "name": CliqueManager.sharedInstance().clique[indexPath.row].song,
                    "artist": CliqueManager.sharedInstance().clique[indexPath.row].artist
                ]

                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/upvote", parameters: p, encoding: .JSON)

                CliqueManager.sharedInstance().clique[indexPath.row].voting_available = false
                CliqueManager.sharedInstance().clique[indexPath.row].votes += 1
                self.table.setEditing(false, animated: true)
                self.table.reloadData()
                if currentclique.leader { self.table.setEditing(true, animated: true) }
            }
        })

        let downvote = UITableViewRowAction(style: .Default, title: "-", handler: {(action, indexpath) in
            if CliqueManager.sharedInstance().clique[indexPath.row].voting_available {
                let p = [
                    "name": CliqueManager.sharedInstance().clique[indexPath.row].song,
                    "artist": CliqueManager.sharedInstance().clique[indexPath.row].artist
                ]

                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/downvote", parameters: p, encoding: .JSON)

                CliqueManager.sharedInstance().clique[indexPath.row].voting_available = false
                CliqueManager.sharedInstance().clique[indexPath.row].votes -= 1
                self.table.setEditing(false, animated: true)
                self.table.reloadData()
                if currentclique.leader { self.table.setEditing(true, animated: true) }
            }
        })

        //let votes = UITableViewRowAction(style: .Default, title: CliqueManager.sharedInstance().clique[indexPath.row].votes.description, handler: {(action, indexpath) in })
        
        let delete = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexpath) in
            let alert = UIAlertController(title: "Delete Song", message: "This song will be removed from the Clique.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .Destructive, handler: { action in
                CliqueManager.sharedInstance().clique.removeAtIndex(indexPath.row)
                tableView.reloadData()
                
                CliqueManager.sharedInstance().updateClique(forAction: .Delete, sourceIndex: indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil))
            
            dispatch_async(dispatch_get_main_queue(), { self.presentViewController(alert, animated: true, completion: nil) })
        })

        upvote.backgroundColor = UIColor.orangeColor()
        //votes.backgroundColor = UIColor.grayColor()
        downvote.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        delete.backgroundColor = UIColor.redColor()
        
        if privatelistening {
            return [delete]
        }
        
        return currentclique.leader ? [upvote, downvote, delete] : [upvote, downvote]
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        if indexPath.section == 1 && CliqueManager.sharedInstance().clique.isEmpty {
            return false
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        switch indexPath.section {
        case 0: return .None
        case 1: return .Delete
        case 2: return .Insert
        default: return .None
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Insert {
            let add = UIAlertController(title: "Add Song", message: "Add this song to Clique?", preferredStyle: .Alert)
            add.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil))
            add.addAction(UIAlertAction(title: "Add", style: .Default, handler: {[unowned self] action in
                switch emptydirective {
                case .library:
                    self.vclibrary[indexPath.row].song["radio"] = false
                    Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: self.vclibrary[indexPath.row].song, encoding: .JSON)
                    
                    self.vclibrary.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 2)], withRowAnimation: .Automatic)
                    
                    for i in 0..<PlayerManager.sharedInstance().library.count {
                        if PlayerManager.sharedInstance().library[i].played {
                            continue
                        } else {
                            PlayerManager.sharedInstance().library[i].played = true
                            break
                        }
                    }
                case .magic:
                    self.magic[indexPath.row].song["radio"] = false
                    Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: self.magic[indexPath.row].song, encoding: .JSON)
                    
                    self.magic.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 2)], withRowAnimation: .Automatic)
                    
                    for i in 0..<PlayerManager.sharedInstance().magic.count {
                        if PlayerManager.sharedInstance().magic[i].played {
                            continue
                        } else {
                            PlayerManager.sharedInstance().magic[i].played = true
                            break
                        }
                    }
                default: break
                }
            }))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(add, animated: true, completion: nil)
            })
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (currentclique.leader && !currentclique.voting && indexPath.section != 0) || indexPath.section == 2 {
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        switch sourceIndexPath.section {
        case 1:
            let item = CliqueManager.sharedInstance().clique[sourceIndexPath.row]
            CliqueManager.sharedInstance().clique.removeAtIndex(sourceIndexPath.row)
            CliqueManager.sharedInstance().clique.insert(item, atIndex: destinationIndexPath.row)
            
            CliqueManager.sharedInstance().updateClique(forAction: .Reorder, sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
        case 2:
            switch emptydirective {
            case .library:
                let item = vclibrary[sourceIndexPath.row]
                vclibrary.removeAtIndex(sourceIndexPath.row)
                vclibrary.insert(item, atIndex: destinationIndexPath.row)
                
                PlayerManager.sharedInstance().library = PlayerManager.sharedInstance().library.filter({ $0.played }) + vclibrary
            case .magic:
                let item = magic[sourceIndexPath.row]
                magic.removeAtIndex(sourceIndexPath.row)
                magic.insert(item, atIndex: destinationIndexPath.row)
                
                PlayerManager.sharedInstance().magic = PlayerManager.sharedInstance().magic.filter({ $0.played }) + magic
            default: break
            }
        default: break
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return NSIndexPath(forRow: row, inSection: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
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
