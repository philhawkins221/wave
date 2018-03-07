//
//  LibraryViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/25/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import SwiftyJSON
import MediaPlayer
import Alamofire

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, MPMediaPickerControllerDelegate {
    
    var list = [[(song: String, artist: String, mpid: String)]](count: 27, repeatedValue: [])
    
    let search = UISearchController(searchResultsController: nil)
    var results = [(song: String, artist: String, mpid: String)]()
    
    enum sortstyle {
        case song
        case artist
        //case playlist
    }
    
    var sort = sortstyle.artist
    
    let viewer = MPMediaPickerController()
    
    //var songs = [MPMediaItem]()
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sortbutton: UIBarButtonItem!
    @IBOutlet weak var updatebutton: UIBarButtonItem!
    
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
        search.searchResultsUpdater = self
        search.hidesNavigationBarDuringPresentation = false
        search.dimsBackgroundDuringPresentation = false
        search.searchBar.sizeToFit()
        table.tableHeaderView = search.searchBar
        
        table.delegate = self
        table.dataSource = self
        
        table.sectionIndexBackgroundColor = UIColor.clearColor()
        search.searchBar.tintColor = self.view.window?.tintColor
        
        viewer.delegate = self
        viewer.allowsPickingMultipleItems = true
        
        if currentclique.leader {
            updatebutton.enabled = true
        } else {
            updatebutton.enabled = false
        }
        
        fetch()
    }
    
    func fetch() {        
        list = [[(song: String, artist: String, mpid: String)]](count: 27, repeatedValue: [])
        
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON {response in
            switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        //print("JSON: \(json)")
                        
                        for song in json["library"].arrayValue {
                            var sortname = String()
                            
                            let title = song["name"].string ?? ""
                            let artist = song["artist"].string ?? ""
                            let mpid = song["mpid"].string ?? ""
                            
                            if self.sort == .artist && artist != "" {
                                sortname = artist
                            } else if self.sort == .song && artist != "" {
                                sortname = title
                            } else {
                                continue
                            }
                            
                            let firstletter = (sortname[0] as String).lowercaseString
                            var index = Int(firstletter.unicodeScalars[firstletter.unicodeScalars.startIndex].value) - 97
                            if index < 0 || index > 25 {
                                index = 26
                            }
                            
                            self.list[index].append((title, artist, mpid))
                        }
                        
                        for i in 0..<self.list.count {
                            if self.sort == .artist {
                                self.list[i] = self.list[i].sort({ $0.artist < $1.artist })
                            } else if self.sort == .song {
                                self.list[i] = self.list[i].sort({ $0.song < $1.song })
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.table.reloadData()
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
        if search.active {
            return 1
        }
        
        return list.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.active {
            return results.count
        }
        
        return list[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("song")
        
        if search.active {
            cell?.textLabel?.text = results[indexPath.row].song
            cell?.detailTextLabel?.text = results[indexPath.row].artist
            
            /*if let pic = results[indexPath.row].artwork {
                cell?.imageView?.image = pic.imageWithSize(CGSize(width: 40, height: 40))
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }*/
        } else {
            cell?.textLabel?.text = list[indexPath.section][indexPath.row].song
            cell?.detailTextLabel?.text = list[indexPath.section][indexPath.row].artist
            
            /*if let pic = list[indexPath.section][indexPath.row].artwork {
                cell?.imageView?.image = pic.imageWithSize(CGSize(width: 40, height: 40))
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }*/
        }
        
        //let widthScale = 50/(cell?.imageView?.image!.size.width)!;
        //let heightScale = 50/(cell?.imageView?.image!.size.height)!
        //cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
        
        cell?.accessoryType = .DisclosureIndicator
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let add = UIAlertController(title: "Add Song", message: "Add this song to clique?", preferredStyle: .Alert)
        add.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: {action in }))
        add.addAction(UIAlertAction(title: "Add", style: .Default, handler: {action in
            var parameters = [String : AnyObject]()
            if self.search.active {
                parameters = [
                    "name": self.results[indexPath.row].song,
                    "artist": self.results[indexPath.row].artist,
                    "mpid": self.results[indexPath.row].mpid,
                    "ytid": "",
                    "spid": "",
                    "scid": "",
                    "amid": "",
                    "votes": 0,
                    "played": false,
                    "radio": false
                ]
            } else {
                parameters = [
                    "name": self.list[indexPath.section][indexPath.row].song,
                    "artist": self.list[indexPath.section][indexPath.row].artist,
                    "mpid": self.list[indexPath.section][indexPath.row].mpid,
                    "ytid": "",
                    "spid": "",
                    "scid": "",
                    "amid": "",
                    "votes": 0,
                    "played": false,
                    "radio": false
                ]
            }
            
            Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: parameters as [String : AnyObject], encoding: .JSON)
        }))
        if search.active {
            search.presentViewController(add, animated: true, completion: nil)
        } else {
            self.presentViewController(add, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if search.active {
            return nil
        }
        
        if section == 26 {
            return "123"
        }
        
        return String(UnicodeScalar(section + 97)).uppercaseString
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "123"]
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if title == "123" {
            return 26
        }
        
        return Int(title.lowercaseString.unicodeScalars[title.lowercaseString.unicodeScalars.startIndex].value) - 97
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
    
    //MARK: - Search Controller Stack
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        results.removeAll()
        
        for letter in list {
            results.appendContentsOf(letter.filter({
                $0.artist.lowercaseString.containsString(search.searchBar.text!.lowercaseString) || $0.song.lowercaseString.containsString(search.searchBar.text!.lowercaseString)
            }))
        }
        
        table.reloadData()
    }
    
    //MARK: - Media Picker Stack
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let warning = UIAlertController(title: "Warning", message: "This selection will replace the entire library.", preferredStyle: .Alert)
        warning.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: {action in
            self.dismissViewControllerAnimated(true, completion: { [unowned pm = PlayerManager.sharedInstance()] in
                
                var newlib = [
                    "songList": [
                        [
                            "name": "",
                            "artist": "",
                            "mpid": ""
                        ]
                    ]
                ]
                
                var mpids = [String]()
                newlib["songList"]?.removeAll()
                
                for song in mediaItemCollection.items {
                    if mpids.contains(song.persistentID.description) {
                        continue
                    }
                    
                    newlib["songList"]?.append([
                        "name": song.title ?? "",
                        "artist": song.artist ?? "",
                        "mpid": song.persistentID.description
                    ])
                    
                    mpids.append(song.persistentID.description)
                    
                    pm.library.removeAll()
                    let newlibentry: [String : AnyObject] = [
                        "name": song.title ?? "",
                        "artist": song.artist ?? "",
                        "mpid": song.persistentID.description,
                        "ytid": "",
                        "spid": "",
                        "scid": "",
                        "amid": "",
                        "votes": 0,
                        "played": false,
                        "radio": false
                    ]
                    pm.library.append((newlibentry, false))
                }
                
                Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/loadSongs", parameters: newlib, encoding: .JSON).responseJSON { response in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.table.reloadData()
                    })
                }
                
                self.fetch()
                mediaPicker.dismissViewControllerAnimated(true, completion: nil)
            })
        }))
        warning.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: {action in }))
        mediaPicker.showViewController(warning, sender: self)
        
        
        
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func update(sender: AnyObject) {
        presentViewController(viewer, animated: true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        if search.active {
            search.active = false
            return
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        fetch()
    }
    
    @IBAction func sortby(sender: AnyObject) {
        let sorter = UIAlertController(title: "Sort By", message: "Rearrange the Library to be sorted:", preferredStyle: .ActionSheet)
        
        sorter.addAction(UIAlertAction(title: "by Song", style: .Default, handler: {action in
            self.sort = .song
            self.sortbutton.title = "Sort By: Song"
            self.fetch()
        }))
        sorter.addAction(UIAlertAction(title: "by Artist", style: .Default, handler: {action in
            self.sort = .artist
            self.sortbutton.title = "Sort By: Artist"
            self.fetch()
        }))
        sorter.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {action in }))
        
        self.presentViewController(sorter, animated: true, completion: nil)
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
