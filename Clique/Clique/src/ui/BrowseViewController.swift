//
//  BrowseViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 12/9/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var profilebar: ProfileBar!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //MARK: - properties
    
    var manager: BrowseManager?
    var search: UISearchController!
    
    var edit = "Edit"
    
    //MARK: - lifecycle stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //manager = BrowseManager(to: self)
        search = UISearchController(searchResultsController: self)
        
        table.canCancelContentTouches = false
        table.delegate = manager?.delegate
        table.dataSource = manager?.delegate
        table.setEditing(false, animated: false)
        
        search.searchBar.placeholder = "search users, songs, or artists"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        //TODO: change edit button to sync if playlist is from am or spotify
        table.setEditing(false, animated: false)
        if let delegate = manager?.delegate as? PlaylistDelegate {
            switch delegate.playlist.library {
            case "applemusic", "spotify": edit = "Sync"
            case "library": edit = "Edit"
            default: break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manager?.update()
                        
        editButton.isEnabled = manager?.client().me() ?? false
        addButton.isEnabled = manager?.client().me() ?? false
        
        if manager?.adding ?? false {
            table.setEditing(true, animated: false)
            editButton.isEnabled = false
        }
        
        if let selected = table.indexPathForSelectedRow {
            table.deselectRow(at: selected, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - storyboard actions
    
    @IBAction func edit(_ sender: Any) {
        switch table.isEditing {
        case true:
            table.setEditing(false, animated: true)
            editButton.title = "Edit"
            addButton.isEnabled = true
        case false:
            table.setEditing(true, animated: true)
            editButton.title = "Done"
            addButton.isEnabled = false
        }
    }
    
    @IBAction func add(_ sender: Any) {
        //TODO: add
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //TODO: set adding to true when showing library then show library
    }
 

}
