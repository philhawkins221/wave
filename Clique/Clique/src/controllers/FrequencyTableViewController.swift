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
    
    func refresh() {
        delegate = FrequencyDelegate()
        tableView.delegate = delegate
        tableView.dataSource = delegate
        tableView.reloadData()
    }

}
