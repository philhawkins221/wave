//
//  SettingsViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 5/10/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import StoreKit
import SwiftyJSON

enum emptydirectives {
    case nothing
    case library
    case magic
}

var emptydirective: emptydirectives = .nothing

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SPTAuthViewDelegate {

    @IBOutlet weak var cliquename: UILabel!
    @IBOutlet weak var passcode: UILabel!
    @IBOutlet weak var votingswitch: UISwitch!
    @IBOutlet weak var spotifyswitch: UISwitch!
    @IBOutlet weak var soundcloudswitch: UISwitch!

    @IBOutlet weak var votinglabel: UILabel!
    @IBOutlet weak var votingdescription: UILabel!
    @IBOutlet weak var spotifylabel: UILabel!
    @IBOutlet weak var spotifydescription: UILabel!
    @IBOutlet weak var soundcloudlabel: UILabel!
    @IBOutlet weak var soundclouddescription: UILabel!

    @IBOutlet weak var emptylabel: UILabel!
    @IBOutlet weak var emptytable: UITableView!
    @IBOutlet weak var tabledescription: UILabel!

    @IBOutlet weak var newclosebutton: UIBarButtonItem!
    @IBOutlet weak var donebutton: UIBarButtonItem!
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emptytable.delegate = self
        emptytable.dataSource = self

        if currentclique.leader {
            if currentclique.spotify {
                spotifyswitch.setOn(true, animated: true)
            } else {
                spotifyswitch.setOn(false, animated: true)
            }

            if currentclique.applemusic {
                soundcloudswitch.setOn(true, animated: true)
            } else {
                soundcloudswitch.setOn(false, animated: true)
            }
        } else {
            votingswitch.hidden = true
            spotifyswitch.hidden = true
            soundcloudswitch.hidden = true

            votinglabel.hidden = true
            votingdescription.hidden = true
            spotifylabel.hidden = true
            spotifydescription.hidden = true
            soundcloudlabel.hidden = true
            soundclouddescription.hidden = true

            emptylabel.hidden = true
            emptytable.hidden = true
            tabledescription.hidden = true
        }

        cliquename.text = currentclique.name
        passcode.text = currentclique.passcode
        
        if creatingnewclique {
            newclosebutton.title = "Cancel"
            newclosebutton.enabled = true
            donebutton.title = "Create"
            
            self.title = currentclique.name + " Settings"
            
            let type = privatelistening ? "Playlist" : "Clique"
            
            let newalert = UIAlertController(title: "New " + type + " Settings", message: "Review and adjust these settings appropriately before creating the " + type + ".", preferredStyle: .Alert)
            newalert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(newalert, animated: true, completion: nil)
        } else {
            soundcloudswitch.enabled = false
            spotifyswitch.enabled = false
        }
        
        switch emptydirective {
        case .nothing:
            emptytable.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .None)
            tableView(emptytable, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        case .library:
            emptytable.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .None)
            tableView(emptytable, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        case .magic:
            emptytable.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .None)
            tableView(emptytable, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0))
        }
    }

    //MARK: - SPTAuthView Stack

    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        authenticationViewController.dismissViewControllerAnimated(true, completion: nil)
        spotifyswitch.setOn(false, animated: true)
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        authenticationViewController.dismissViewControllerAnimated(true, completion: nil)
        spotifyswitch.setOn(false, animated: true)
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("YAAAAAAAAS")
        currentclique.spotify = true
        spotifysession = session
        //also save it to server and data store?

        authenticationViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func votingChanged(sender: AnyObject) {
    }

    @IBAction func spotifyChanged(sender: AnyObject) {
        if spotifyswitch.on {
            //change 'spotify' member of clique in server

            if (spotifysession == nil) {
                // No session at all - use SPTAuth to ask the user
                // for access to their account.

                let auth = SPTAuth.defaultInstance()
                auth.clientID = kClientId
                auth.redirectURL = NSURL(string: kCallbackURL)
                auth.requestedScopes = [SPTAuthStreamingScope]

                let authorizer = SPTAuthViewController.authenticationViewController()
                authorizer.delegate = self

                self.presentViewController(authorizer, animated: true, completion: nil)
                return
            } else if (spotifysession!.isValid()) {
                // Our session is valid - go straight to music playback.

                return
            } else {
                // Session expired - we need to refresh it before continuing.
                // This process doesn't involve user interaction unless it fails.

                SPTAuth.defaultInstance().renewSession(spotifysession, callback: {(error, session) in
                    if error == nil {
                        print(error)
                    }

                    spotifysession = session
                })

                return
            }
        } else {
            //TODO: set spotify member to false locally, in server, and in data store
        }


    }

    //MARK: - TableView Stack

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("empty")
        cell?.accessoryType = .None

        if indexPath.row == 0 {
            cell?.textLabel?.text = "Do nothing"
        } else if indexPath.row == 1 {
            cell?.textLabel?.text = "Play songs randomly from Music Library"
        } else if indexPath.row == 2 {
            cell?.textLabel?.text = "Play songs from custom playlist generated by MagicPlaylist"
        }

        switch emptydirective {
        case .nothing: if indexPath.row == 0 { cell?.accessoryType = .Checkmark }
        case .library: if indexPath.row == 0 { cell?.accessoryType = .Checkmark }
        case .magic: if indexPath.row == 0 { cell?.accessoryType = .Checkmark }
        }

        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        for i in 0 ..< 3 {
            if i == indexPath.row {
                //update empty directive
                if i == 0 { emptydirective = .nothing } else if i == 1 { emptydirective = .library } else if i == 2 { emptydirective = .magic }

                emptytable.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))?.accessoryType = .Checkmark
            } else {
                emptytable.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))?.accessoryType = .None
            }
        }
    }

    @IBAction func soundcloudChanged(sender: AnyObject) { //actually apple music
        //TODO: needs to remember that apple music has been enabled/disabled
        if soundcloudswitch.on {
            if #available(iOS 9.3, *) {
                SKCloudServiceController.requestAuthorization({
                    if $0 == SKCloudServiceAuthorizationStatus.Authorized {
                        SKCloudServiceController().requestCapabilitiesWithCompletionHandler({ [unowned self](status, error) in
                            if status.contains(.MusicCatalogPlayback) {
                                if let error = error {
                                    print(error)
                                    //didn't make it
                                    let nope = UIAlertController(title: "Error", message: "An error occured while trying to connect an Apple Music account.", preferredStyle: .Alert)
                                    nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                    self.presentViewController(nope, animated: true, completion: nil)
                                    dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                                        self.soundcloudswitch.setOn(false, animated: true)
                                    })

                                    return
                                }
                                //made it
                                currentclique.applemusic = true
                                //save to server and store?

                            } else {
                                //didn't make it
                                let nope = UIAlertController(title: "Unsuccessful", message: "An Apple Music account could not be connected.", preferredStyle: .Alert)
                                nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                                    self.presentViewController(nope, animated: true, completion: nil)
                                    self.soundcloudswitch.setOn(false, animated: true)
                                })
                            }
                        })
                    }

                })
            } else {
                let nope = UIAlertController(title: "Update Required", message: "An Apple Music account can only be connected if iOS 9.3 or later is available.", preferredStyle: .Alert)
                nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(nope, animated: true, completion: nil)
                self.soundcloudswitch.setOn(false, animated: true)
            }
        }
    }

    @IBAction func done(sender: AnyObject) {
        if donebutton.title == "Create" {
            
            let newclique: [String : AnyObject] = [
                "name": currentclique.name,
                "passcode": currentclique.passcode,
                "currentSong": "",
                "artist": "",
                "voting": currentclique.voting,
                "applemusic": currentclique.applemusic,
                "spotify": currentclique.spotify,
                "library": [],
                "songList": []
            ]
            
            Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/", parameters: newclique, encoding: .JSON).response { (request, response, data, error) in
                
                Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/").responseJSON { [weak self] response in
                    
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            
                            //get new clique id
                            for clique in json.array ?? [] {
                                if clique["name"].string ?? "" == currentclique.name {
                                    currentclique.id = clique["_id"].stringValue
                                    print("new id:", currentclique.id)
                                    
                                    break
                                }
                            }
                            
                            //save new clique
                            //1
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            let managedContext = appDelegate.managedObjectContext
                            
                            //2
                            var entity = NSEntityDescription()
                            
                            if privatelistening {
                                entity = NSEntityDescription.entityForName("Playlist", inManagedObjectContext: managedContext)!
                            } else {
                                entity = NSEntityDescription.entityForName("Clique", inManagedObjectContext: managedContext)!
                            }
                            
                            let newclique = NSManagedObject(entity: entity, insertIntoManagedObjectContext:managedContext)
                            
                            //3
                            newclique.setValue(currentclique.id, forKey: "id")
                            newclique.setValue(currentclique.name, forKey: "name")
                            newclique.setValue(currentclique.passcode, forKey: "passcode")
                            newclique.setValue(true, forKey: "isLeader")
                            newclique.setValue(currentclique.applemusic, forKey: "applemusic")
                            newclique.setValue(currentclique.spotify, forKey: "spotify")
                            newclique.setValue(true, forKey: "voting")
                            
                            //finish up
                            print(newclique)
                            print(currentclique)
                            appDelegate.saveContext()
                            creatingnewclique = false
                            dispatch_async(dispatch_get_main_queue(), {
                                if let settings = self {
                                    settings.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                }
                            })
                        }
                    case .Failure(let error):
                        print("2:", error)
                        
                        return
                    }
                }
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func newclose(sender: AnyObject) {
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
