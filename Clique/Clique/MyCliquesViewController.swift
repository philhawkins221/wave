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

import UIKit

var nowplaying = false
var currentsong: (song: String, artist: String, artwork: String?) = ("", "", nil)

class MyCliquesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        table.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        table.delegate = self
        table.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView Stack
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if nowplaying {
            return 4
        }
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("song")
        if indexPath.section == 0 && nowplaying {
            cell?.textLabel?.text = currentsong.song
            cell?.detailTextLabel?.text = currentsong.artist
            if currentsong.artwork != nil {
                cell?.imageView?.sd_setImageWithURL(NSURL(string: currentsong.artwork!))
            } else {
                cell?.imageView?.image = UIImage(named: "genericart.png")
            }
            //cell?.imageView?.decreaseSize(self)
            let widthScale = 40/(cell?.imageView?.image!.size.width)!;
            let heightScale = 40/(cell?.imageView?.image!.size.height)!;
            cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale);
            
        } else {
            cell?.textLabel?.text = "Clique"
            cell?.detailTextLabel?.text = "0 Members"
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("clique")
        showViewController(vc!, sender: self)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if nowplaying {
            if section == 0 {
                return "Now Playing"
            } else if section == 1 {
                return "Leader"
            } else if section == 2 {
                return "Active"
            } else if section == 3 {
                return "Inactive"
            }
        } else {
            if section == 0 {
                return "Leader"
            } else if section == 1 {
                return "Active"
            } else if section == 2 {
                return "Inactive"
            }
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let leaveAction = UITableViewRowAction(style: .Default, title: "Leave", handler: {(action, indexpath) in })
        leaveAction.backgroundColor = UIColor.redColor()
        leaveAction.backgroundEffect = .None
        
        return [leaveAction]
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
