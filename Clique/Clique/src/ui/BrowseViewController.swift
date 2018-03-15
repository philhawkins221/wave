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
    let search = UISearchController(searchResultsController: nil)
    
    var adding = false
    var final = false
    var mode: BrowseMode = .friends
    var searching: SearchMode = .none
    var query = ""
    var catalog: CatalogItem = Artist(id: "", library: "", name: "")
    var end: BrowseMode?
    
    var user = Identity.me
    var playlist = Playlist(
        owner: "",
        id: "",
        library: "",
        name: "",
        social: false,
        songs: []
    )
    
    //MARK: - lifecycle stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        
        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        search.searchBar.placeholder = "search users, songs, or artists"
        search.hidesNavigationBarDuringPresentation = false
        search.dimsBackgroundDuringPresentation = false
        search.searchBar.sizeToFit()
        search.searchBar.tintColor = UIColor.orange
        
        table.tableHeaderView = search.searchBar
        table.tintColor = UIColor.orange
        table.canCancelContentTouches = false

        addButton.isEnabled = false
        editButton.isEnabled = false
        
        if adding {
            table.setEditing(true, animated: false)
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
        
        if adding || final {
            addButton.isEnabled = false
            editButton.isEnabled = false
        }
        
        if let selected = table.indexPathForSelectedRow {
            table.deselectRow(at: selected, animated: true)
        }
        
        if let delegate = manager?.delegate as? PlaylistDelegate {
            switch delegate.playlist.library {
            case "applemusic", "spotify": editButton.title = "Sync"
            default: break
            }
        }
        
        if final && mode == .friends { //TODO: bad condition
            search.isActive = true
            search.searchBar.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tasks
    
    func refresh() {
        manager = BrowseManager(to: self)
        search.searchResultsUpdater = manager?.delegate
        table.delegate = manager?.delegate
        table.dataSource = manager?.delegate
        table.reloadData()
    }
    
    //MARK: - actions
    
    @IBAction func edit(_ sender: Any) {
        guard editButton.title != "Sync" else { return manager?.sync() ?? () }
        
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
    
    //MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? BrowseViewController else { return }
        
        switch mode {
        case .friends, .playlist: manager?.search(for: mode, on: vc)
        case .library: break //TODO: add playlist alert
        case .browse, .sync, .search, .catalog: break
        }
    }

}
