//
//  CliqueViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 1/19/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit

class CliqueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
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
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("song")
        
        cell?.textLabel?.text = "Song"
        cell?.detailTextLabel?.text = "Artist"
        cell?.imageView?.image = UIImage(named: "genericart.png")
        
        let widthScale = 40/(cell?.imageView?.image!.size.width)!;
        let heightScale = 40/(cell?.imageView?.image!.size.height)!
        cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
            
        
        if indexPath.section == 0 {
            cell?.accessoryType = .None
        } else {
            cell?.accessoryType = .DisclosureIndicator
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
        if indexPath.section == 0 {
            return nil
        }
        
        let upvote = UITableViewRowAction(style: .Default, title: "+", handler: {(action, indexpath) in })
        let downvote = UITableViewRowAction(style: .Default, title: "-", handler: {(action, indexpath) in })
        downvote.backgroundColor = UIColor.redColor()
        downvote.backgroundEffect = .None
                
        return [upvote, downvote]
    }
    
    @IBAction func addButton(sender: AnyObject) {
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
