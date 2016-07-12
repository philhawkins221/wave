//
//  JoinViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 4/20/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class JoinViewController: UIViewController {

    @IBOutlet weak var nametext: UITextField!
    @IBOutlet weak var passcode: UITextField!
    @IBOutlet weak var joinbutton: UIButton!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func join(sender: AnyObject) {
        joinbutton.enabled = false
        Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/").responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let cliques = json.array ?? []
                    var passed = false
                    
                    for clique in cliques { //nil-checking not present
                        if clique["name"].string == self.nametext.text && clique["passcode"].string == self.passcode.text {
                            //you in
                            
                            //save new clique
                            //1
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            let managedContext = appDelegate.managedObjectContext
                            
                            //2
                            let entity =  NSEntityDescription.entityForName("Clique", inManagedObjectContext: managedContext)
                            let newclique = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                            
                            //3
                            newclique.setValue(clique["_id"].string ?? "", forKey: "id")
                            newclique.setValue(self.nametext.text, forKey: "name")
                            newclique.setValue(self.passcode.text, forKey: "passcode")
                            newclique.setValue(false, forKey: "isLeader")
                            newclique.setValue(false, forKey: "applemusic")
                            newclique.setValue(false, forKey: "spotify")
                            newclique.setValue(true, forKey: "voting")
                            
                            //finish up
                            passed = true
                            appDelegate.saveContext()
                            self.dismissViewControllerAnimated(true, completion: nil)

                            break
                        }
                    }
                    
                    if !passed {
                        self.joinbutton.enabled = true
                        
                        let nope = UIAlertController(title: "Sorry", message: "The Clique name and passcode didn't match anything.", preferredStyle: .Alert)
                        nope.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.presentViewController(nope, animated: true, completion: nil)
                    }
                }
            case .Failure(let error):
                print(error)
                self.joinbutton.enabled = true
            }
        }
    }

    @IBAction func close(sender: AnyObject) {
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
