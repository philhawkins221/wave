//
//  FrequencyTableViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 4/4/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit

class FrequencyTableViewController: UITableViewController {
    
    var delegate: FrequencyDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        //refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        delegate = FrequencyDelegate()
        tableView.delegate = delegate
        tableView.dataSource = delegate
        //print(delegate)
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
