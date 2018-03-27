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
    @IBOutlet weak var options: UIView!
    @IBOutlet weak var optionscover: UIView!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //MARK: - properties
    
    var manager: BrowseManager?
    var search = UISearchController(searchResultsController: nil)
    
    var adding = false
    var final = false
    var mode: BrowseMode = .friends
    var searching: SearchMode = .none
    var query = ""
    var catalog: CatalogItem = Artist(id: "", library: "", name: "")
    var end: BrowseMode?
    
    var user = Identity.me
    var playlist = Playlist()
    
    
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
        
        profilebar.controller = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if adding { table.setEditing(true, animated: false) }
        if mode == .friends { table.setEditing(false, animated: false) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
        
        if adding || final {
            addButton.isEnabled = false
            editButton.isEnabled = false
        }
        
        if let selected = table.indexPathForSelectedRow { table.deselectRow(at: selected, animated: true) }
        
        if mode == .playlist {
            switch playlist.library {
            case Catalogues.AppleMusic.rawValue, Catalogues.Spotify.rawValue: editButton.title = "sync"
            default: break
            }
        }
        
        if !(manager?.client().me() ?? true) { editButton.title = "" }
        
        if final && mode == .friends {
            DispatchQueue.main.async { [unowned self] in
                self.search.isActive = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        search.searchBar.resignFirstResponder()
        search.isActive = false
        
        if mode == .friends { table.setEditing(false, animated: false) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tasks
    
    func refresh() {
        manager = BrowseManager(to: self)
        search.delegate = manager?.delegate
        search.searchResultsUpdater = manager?.delegate
        table.delegate = manager?.delegate
        table.dataSource = manager?.delegate
        table.reloadData()
    }
    
    //MARK: - actions
    
    @IBAction func edit(_ sender: Any) {
        guard editButton.title != "sync" else { return Alerts.sync(playlist: (), on: self) }
        
        switch table.isEditing {
        case true:
            table.setEditing(false, animated: true)
            editButton.title = "edit"
            addButton.isEnabled = true
        case false:
            table.setEditing(true, animated: true)
            editButton.title = "done"
            addButton.isEnabled = false
        }
    }
    
    //MARK: - navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "search": return true
        case "add":
            switch mode {
            case .library:
                Alerts.add(playlist: (), on: self)
                return false
            case .browse, .friends, .playlist, .sync, .search, .catalog: return true
            }
        default: return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
            
        case "add", "search":
            guard let vc = segue.destination as? BrowseViewController else { return }
            switch mode {
            case .friends, .playlist: manager?.search(for: mode, on: vc)
            case .browse, .library, .sync, .search, .catalog: break
            }
            
        case "options":
            guard let vc = segue.destination as? OptionsTableViewController else { return }
            profilebar.options = vc
            profilebar.optionscontainer = options
            profilebar.optionscover = optionscover
            vc.profilebar = profilebar
        default: break
        }
    }

}
