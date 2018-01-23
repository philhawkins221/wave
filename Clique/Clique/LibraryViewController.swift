//
//  LibraryViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 12/9/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    
    //MARK: - storyboard outlets
    
    @IBOutlet weak var profilebar: ProfileBar!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //MARK: - lifecycle methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        try! LibraryManager.manage(controller: self)
        LibraryManager.sharedInstance().update()
        
        if navigationController?.viewControllers.count == 1 {
            try? LibraryManager.manage(display: nil)
        }
        
        if let selected = table.indexPathForSelectedRow {
            table.deselectRow(at: selected, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.delegate = LibraryManager.sharedInstance().delegate
        table.dataSource = LibraryManager.sharedInstance().delegate
        
        profilebar.controller = .lib
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - storyboard actions
    @IBAction func edit(_ sender: Any) {
        
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //TODO: set adding to true when showing library then show library
    }
 

}
