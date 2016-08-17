//
//  MyCliquesViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/16/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

extension String {

    subscript (i: Int) -> Character {
        //return self[advance(self.startIndex, i)]
        return self[self.startIndex.advancedBy(i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        //return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
        return substringWithRange(Range(start: self.startIndex.advancedBy(r.startIndex), end: self.startIndex.advancedBy(r.endIndex)))
    }
}

var scClientID = "2c9d9d500b26f5a1ae7661215c5b4e1c"
var scClientSecret = "1745f37d41a47591147470a84acda2c5"

var privatelistening = false

let blue = UIColor(red: 20/255, green: 154/255, blue: 233/255, alpha: 1)

import UIKit
import CoreData
import StoreKit
import MediaPlayer

var nowplaying = false
var currentsong: (song: String, artist: String, album: String, artwork: String?, time: Double) = ("", "", "", nil, 0)

class MyCliquesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var cliques = [NSManagedObject]()
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var listeningbutton: UIButton!
    @IBOutlet weak var joinbutton: UIBarButtonItem!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        table.delegate = self
        table.dataSource = self
        table.hidden = true
    
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
        
        if privatelistening {
            joinbutton.title = "Saved"
            joinbutton.enabled = true
            
            listeningbutton.setTitle("Public Listening", forState: .Normal)
            listeningbutton.backgroundColor = UIColor.orangeColor()
            
            title = "My Playlists"
        } else {
            joinbutton.title = "Join"
            joinbutton.enabled = true
            
            listeningbutton.setTitle("Private Listening", forState: .Normal)
            listeningbutton.backgroundColor = blue
            
            title = "My Cliques"
        }

        fetch()

        //test()

        //table.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //table.delegate = self
        //table.dataSource = self

        //fetch()
    }

    func fetch() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        //2
        let cliqueRequest: NSFetchRequest
        if privatelistening {
            cliqueRequest = NSFetchRequest(entityName: "Playlist")
        } else {
            cliqueRequest = NSFetchRequest(entityName:"Clique")
        }
        
        //3
        do {
            cliques = try managedContext.executeFetchRequest(cliqueRequest) as! [NSManagedObject]
        } catch {
            print(error)
        }

        table.reloadData()
        table.hidden = false
        
        if cliques.isEmpty && privatelistening {
            let help = UIAlertController(title: "Me, Myself, and I...", message: "In Private Listening, only you can see songs that are playing and add to Up Next.", preferredStyle: .Alert)
            help.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(help, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func test() {
        if #available(iOS 9.3, *) {
            print("hello???")
            SKCloudServiceController.requestAuthorization({
                if $0 == SKCloudServiceAuthorizationStatus.Authorized {
                    SKCloudServiceController().requestCapabilitiesWithCompletionHandler({ [unowned self](status, error) in
                        if status.contains(.MusicCatalogPlayback) {
                            if let error = error {
                                print(error)
                                return
                            }

                            let trackID = "302053341"
                            let controller = MPMusicPlayerController.applicationMusicPlayer()
                            controller.setQueueWithStoreIDs([trackID])
                            controller.play()

                            self.presentViewController(UIAlertController(title: "RICK ROLL", message: "LOLOLOLOLOLOLOL", preferredStyle: .Alert), animated: true, completion: nil)
                        } else {
                            print("skcloudservicecapability status was not the good one")
                        }
                    })
                } else {
                    print("skcloudauthorizationstatus was not the good one")
                }
            })
        } else {
            // Fallback on earlier versions
            print("you shithead")
        }
    }

    //MARK: - TableView Stack

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if nowplaying {
            return 2
        }
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nowplaying {
            if section == 0 {
                return 1
            }
        }
        return cliques.isEmpty ? 1 : cliques.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("song")

        if cliques.isEmpty && !(nowplaying && indexPath.section == 0) {
            if !privatelistening {
                cell?.textLabel?.text = "You're not in any Cliques"
                cell?.detailTextLabel?.text = "Join a Clique or start a new one of your own!"
            } else {
                cell?.textLabel?.text = "You don't have any playlists"
                cell?.detailTextLabel?.text = "Tap the New button to make a playlist"
            }
            
            cell?.detailTextLabel?.textColor = UIColor.blackColor()
            
            return cell!
        }

        if indexPath.section == 0 && nowplaying {
            cell?.textLabel?.text = currentsong.song
            cell?.detailTextLabel?.text = currentsong.artist
            if currentsong.artwork != nil {
                cell?.imageView?.sd_setImageWithURL(NSURL(string: currentsong.artwork!))
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }
            //cell?.imageView?.decreaseSize(self)
            let widthScale = 40/(cell?.imageView?.image!.size.width)!
            let heightScale = 40/(cell?.imageView?.image!.size.height)!
            cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
            cell?.accessoryType = .None
        } else {
            cell?.textLabel?.text = cliques[indexPath.row].valueForKey("name") as? String
            if cliques[indexPath.row].valueForKey("isLeader") as! Bool {
                cell?.detailTextLabel?.text = "Leader"
                cell?.detailTextLabel?.textColor = view.window?.tintColor
            } else {
                cell?.detailTextLabel?.text = "Member"
                cell?.detailTextLabel?.textColor = UIColor.lightGrayColor()
            }
            cell?.imageView?.image = nil
        }
        
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if cliques.isEmpty || (nowplaying && indexPath.section == 0) {
            return
        }
        
        currentclique = (
            cliques[indexPath.row].valueForKey("id") as! String,
            cliques[indexPath.row].valueForKey("isLeader") as! Bool,
            cliques[indexPath.row].valueForKey("name") as! String,
            cliques[indexPath.row].valueForKey("passcode") as! String,
            cliques[indexPath.row].valueForKey("applemusic") as! Bool,
            cliques[indexPath.row].valueForKey("spotify") as! Bool,
            privatelistening ? false : cliques[indexPath.row].valueForKey("voting") as! Bool
        )
        
        PlayerManager.sharedInstance().library.removeAll()

        //testing purposes only
        //currentclique.id = "56e78abf3cd0360300a44076"
        //currentclique.leader = true

        let vc = storyboard?.instantiateViewControllerWithIdentifier("clique")
        showViewController(vc!, sender: self)
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if nowplaying {
            if section == 0 {
                return "Now Playing"
            } else if section == 1 {
                return privatelistening ? "Playlists" : "Cliques"
            }
        }

        return privatelistening ? "Playlists" : "Cliques"
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let leaveAction = UITableViewRowAction(style: .Default, title: "Leave", handler: {[unowned self](action, indexpath) in
            
            //delete from store
            (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext.deleteObject(self.cliques[indexPath.row])
            
            //remove from array
            self.cliques.removeAtIndex(indexPath.row)
            
            //remove from table
            self.table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            //self.fetch()
            
            
        })
        leaveAction.backgroundColor = UIColor.redColor()
        leaveAction.backgroundEffect = .None

        return [leaveAction]
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
    
    @IBAction func listeningchange(sender: AnyObject) {
        privatelistening = !privatelistening
        
        if privatelistening {
            //UIApplication.sharedApplication().keyWindow?.tintColor = blue
            self.view.window?.tintColor = blue
        } else {
            //UIApplication.sharedApplication().keyWindow?.tintColor = UIColor.orangeColor()
            self.view.window?.tintColor = UIColor.orangeColor()
        }
        
        viewWillAppear(true)
    }
    
    @IBAction func joinOrSaved(sender: AnyObject) {
        if !privatelistening {
            let joinnav = storyboard?.instantiateViewControllerWithIdentifier("joinnav")
            presentViewController(joinnav!, animated: true, completion: nil)
        } else {
            let savednav = storyboard?.instantiateViewControllerWithIdentifier("savednav")
            presentViewController(savednav!, animated: true, completion: nil)
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
