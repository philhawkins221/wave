//
//  SavedViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 7/7/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import SDWebImage

class SavedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var saves = [[String]]()
    @IBOutlet weak var table: UITableView!
    
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
        table.delegate = self
        table.dataSource = self
        
        fetch()
        table.reloadData()
    }
    
    func fetch() {
        saves = NSUserDefaults.standardUserDefaults().objectForKey("Saved") as? [[String]] ?? []
        print(saves)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saves.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCellWithIdentifier("saveditem")
        
        cell?.textLabel?.text = saves[indexPath.row][0]
        cell?.detailTextLabel?.text = saves[indexPath.row][1]
        cell?.imageView?.sd_setImageWithURL(NSURL(string: saves[indexPath.row][2]), placeholderImage: UIImage(named: "genericart.png")!)
        
        if cell?.imageView?.image != nil {
            let widthScale = 50/(cell?.imageView?.image!.size.width)!
            let heightScale = 50/(cell?.imageView?.image!.size.height)!
            cell!.imageView!.transform = CGAffineTransformMakeScale(widthScale, heightScale)
        }
        
        return cell!
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
