//
//  NewCliqueViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 6/3/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

var creatingnewclique = false

class NewCliqueViewController: UIViewController {

    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var passcodefield: UITextField!
    @IBOutlet weak var nextbutton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        if privatelistening {
            passcodefield.enabled = false
            passcodefield.hidden = true
            passcodefield.text = "none"
        }
        
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
        namefield.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func create(sender: AnyObject) {
        nextbutton.enabled = false
        
        if privatelistening {
            if namefield.text == "" || passcodefield.text == "" {
                nextbutton.enabled = true
                let nope = UIAlertController(title: "Entry Required", message: "The fields cannot be left empty.", preferredStyle: .Alert)
                nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                
                presentViewController(nope, animated: true, completion: nil)
                return
            }
            
            var playlists = [NSManagedObject]()
            do {
                playlists = try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "Playlist")) as! [NSManagedObject]
            } catch {
                print(error)
            }
            
            let playlistnames = playlists.map({ $0.valueForKey("name") as! String })
            
            if playlistnames.contains(self.namefield.text!) {
                nextbutton.enabled = true
                let nope = UIAlertController(title: "Playlist Already Exists", message: "Please choose a new name for your playlist and try again.", preferredStyle: .Alert)
                nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                
                dispatch_async(dispatch_get_main_queue(), { self.presentViewController(nope, animated: true, completion: nil) })
                return
            } else {
                currentclique = ("", true, self.namefield.text!, self.passcodefield.text!, false, false, true)
                
                creatingnewclique = true
                let settings = self.storyboard?.instantiateViewControllerWithIdentifier("settingsnav")
                dispatch_async(dispatch_get_main_queue(), { self.presentViewController(settings!, animated: true, completion: nil) })
            }
            
            return
        }
        
        if namefield.text == "" || passcodefield.text == "" {
            nextbutton.enabled = true
            let nope = UIAlertController(title: "Entry Required", message: "The Clique name and passcode fields cannot be left empty.", preferredStyle: .Alert)
            nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(nope, animated: true, completion: nil)
            return
        }
        
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists").responseJSON { [unowned self] response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    var names = [String]()
                    
                    for clique in json.array ?? [] {
                        names.append(clique["name"].string ?? "")
                    }
                    
                    if names.contains(self.namefield.text!) {
                        self.nextbutton.enabled = true
                        let nope = UIAlertController(title: "Clique Name Taken", message: "This name is already in use. Please choose a new name and try again.", preferredStyle: .Alert)
                        nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        
                        dispatch_async(dispatch_get_main_queue(), { self.presentViewController(nope, animated: true, completion: nil) })
                        return
                    } else {
                        currentclique = ("", true, self.namefield.text!, self.passcodefield.text!, false, false, true)
                        
                        creatingnewclique = true
                        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("settingsnav")
                        dispatch_async(dispatch_get_main_queue(), { self.presentViewController(settings!, animated: true, completion: nil) })
                    }
                }
            case .Failure(let error):
                print(error)
                self.nextbutton.enabled = true
            }
        }
    }

    @IBAction func close(sender: AnyObject) {
        creatingnewclique = false
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
