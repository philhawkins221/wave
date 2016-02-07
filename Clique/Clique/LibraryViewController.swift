//
//  LibraryViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/25/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import MediaPlayer

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var list = [[(song: String, artist: String, artwork: MPMediaItemArtwork?)]](count: 27, repeatedValue: [])
    
    let search = UISearchController(searchResultsController: nil)
    var results = [(song: String, artist: String, artwork: MPMediaItemArtwork?)]()
    
    enum sortstyle {
        case song
        case artist
        //case playlist
    }
    
    var sort = sortstyle.artist
    
    var songs = [MPMediaItem]()
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sortbutton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        search.searchResultsUpdater = self
        search.hidesNavigationBarDuringPresentation = true
        search.dimsBackgroundDuringPresentation = false
        search.searchBar.sizeToFit()
        table.tableHeaderView = search.searchBar
        
        table.delegate = self
        table.dataSource = self
        
        table.sectionIndexBackgroundColor = UIColor.clearColor()
        
        fetch()
    }
    
    func fetch() {
        songs = MPMediaQuery.songsQuery().items!
        list = [[(song: String, artist: String, artwork: MPMediaItemArtwork?)]](count: 27, repeatedValue: [])
        
        for song in songs {
            var sortname = String()
            let title = song.valueForProperty(MPMediaItemPropertyTitle) as? String ?? "No Title"
            let artist = song.valueForProperty(MPMediaItemPropertyArtist) as? String ?? "No Artist"
            let artwork = song.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            
            if sort == .artist {
                sortname = artist
            } else if sort == .song {
                sortname = title
            }
            
            let firstletter = (sortname[0] as String).lowercaseString
            var index = Int(firstletter.unicodeScalars[firstletter.unicodeScalars.startIndex].value) - 97
            if index < 0 || index > 25 {
                index = 26
            }
            
            list[index].append((title, artist, artwork))
        }
        
        for var i = 0; i < list.count; i++ {
            if sort == .artist {
                list[i] = list[i].sort({ $0.artist < $1.artist })
            } else if sort == .song {
                list[i] = list[i].sort({ $0.song < $1.song })
            }
        }
        
        table.reloadData()
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
            
            if let pic = results[indexPath.row].artwork {
                cell?.imageView?.image = pic.imageWithSize(CGSize(width: 40, height: 40))
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }
        } else {
            cell?.textLabel?.text = list[indexPath.section][indexPath.row].song
            cell?.detailTextLabel?.text = list[indexPath.section][indexPath.row].artist
            
            if let pic = list[indexPath.section][indexPath.row].artwork {
                cell?.imageView?.image = pic.imageWithSize(CGSize(width: 40, height: 40))
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }
        }
        
        let widthScale = 50/(cell?.imageView?.image!.size.width)!;
        let heightScale = 50/(cell?.imageView?.image!.size.height)!
        cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
        
        cell?.accessoryType = .None
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        results.removeAll()
        
        for letter in list {
            results.appendContentsOf(letter.filter({
                $0.artist.lowercaseString.containsString(search.searchBar.text!.lowercaseString) || $0.song.lowercaseString.containsString(search.searchBar.text!.lowercaseString)
            }))
        }
        
        table.reloadData()
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
