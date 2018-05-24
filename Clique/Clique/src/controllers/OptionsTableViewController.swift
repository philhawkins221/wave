//
//  OptionsTableViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 3/24/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit

class OptionsTableViewController: UITableViewController {
    
    //MARK: - properties
    
    var manager: OptionsManager?
    var profilebar: ProfileBar?
    
    //MARK: - lifecycle stack

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = true
        tableView.alpha = 1
        tableView.isScrollEnabled = false
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    func refresh() {
        manager = OptionsManager(to: self, with: profilebar)
        tableView.delegate = manager?.delegate
        tableView.dataSource = manager?.delegate
        tableView.reloadData()
        manager?.selections.forEach {
            let ip = IndexPath(row: $0, section: 0)
            tableView.selectRow(at: ip, animated: false, scrollPosition: .none)
        }
        
        var ends = [
            IndexPath(row: 0, section: 0),
            IndexPath(row: Options.options.options.count - 1, section: 0),
        ]
        
        if Options.options.stop != nil { ends.append(IndexPath(row: 0, section: 1)) }
    }

}
