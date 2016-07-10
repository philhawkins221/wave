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

    var timer = NSTimer()

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
            }
        }
        
        CliqueManager.sharedInstance().fetch()
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
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return CliqueManager.sharedInstance().clique.count
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

            if CliqueManager.sharedInstance().clique.isEmpty {
                cell?.textLabel?.text = "Clique is Empty"
                cell?.detailTextLabel?.text = "Press the add button below to start listening"
                cell?.voteslabel.text = ""

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
        } else { //TODO: - get current song, maybe do this in fetch()
            cell?.textLabel?.text = CliqueManager.sharedInstance().currentSong.name
            cell?.detailTextLabel?.text = CliqueManager.sharedInstance().currentSong.artist
            cell?.imageView?.sd_setImageWithURL(NSURL(string: CliqueManager.sharedInstance().currentSong.artwork), placeholderImage: UIImage(named: "genericart.png")!)
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
        }

        return nil
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 || privatelistening {
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
                self.table.setEditing(false, animated: false)
                self.table.reloadData()
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
            }
        })

        let votes = UITableViewRowAction(style: .Default, title: CliqueManager.sharedInstance().clique[indexPath.row].votes.description, handler: {(action, indexpath) in })
        
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
        votes.backgroundColor = UIColor.grayColor()
        downvote.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        delete.backgroundColor = UIColor.redColor()
        
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
        return indexPath.section == 0 ? false : true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return indexPath.section == 0 ? .None : .Delete
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if currentclique.leader && !currentclique.voting && indexPath.section != 0 {
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item = CliqueManager.sharedInstance().clique[sourceIndexPath.row]
        CliqueManager.sharedInstance().clique.removeAtIndex(sourceIndexPath.row)
        CliqueManager.sharedInstance().clique.insert(item, atIndex: destinationIndexPath.row)
        
        CliqueManager.sharedInstance().updateClique(forAction: .Reorder, sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
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
