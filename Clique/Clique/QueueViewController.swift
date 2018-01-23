//
//  QueueViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 12/9/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class QueueViewController: UIViewController {
    
    //MARK: - storyboard outlets

    @IBOutlet weak var profilebar: ProfileBar!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var historybutton: UIBarButtonItem!
    @IBOutlet weak var addbutton: UIBarButtonItem!
    
    //MARK: - lifecycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationControllerStyleGuide.enforce(on: navigationController) //needs to be inout?
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        if let selected = table.indexPathForSelectedRow {
            table.deselectRow(at: selected, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        QueueManager.sharedInstance().update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = QueueManager.sharedInstance().delegate
        table.dataSource = QueueManager.sharedInstance().delegate
        
        profilebar.controller = .q
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - storyboard actions
    

    
    //MARK: - navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //TODO: history
        //TODO: add
    }
    

}
