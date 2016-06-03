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

var creatingnewclique = false

class NewCliqueViewController: UIViewController {

    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var passcodefield: UITextField!
    
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
        if namefield.text == "" || passcodefield.text == "" {
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
