//
//  QueueViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 12/9/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class QueueViewController: UIViewController {
    
    //MARK: - outlets

    @IBOutlet weak var profilebar: ProfileBar!
    @IBOutlet weak var options: UIView!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var historybutton: UIBarButtonItem!
    @IBOutlet weak var addbutton: UIBarButtonItem!
    
    //MARK: - properties
    
    var manager: QueueManager?
    
    var mode: QueueMode = .queue
    var user = Identity.me
    var fill: Playlist?
    
    let refreshcontrol = UIRefreshControl()
    weak var timer = Timer()
    
    //MARK: - lifecycle stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
                        
        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        table.tintColor = UIColor.orange
        table.canCancelContentTouches = false
        
        profilebar.controller = self
        
        refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            table.refreshControl = refreshcontrol
        } else {
            table.backgroundView = refreshcontrol
        }
                
        //TODO: timer and notifications
        //NotificationCenter.default.addObserver(self, selector: #selector(self.advance), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if manager?.client().me() ?? false { table.setEditing(true, animated: false) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
        
        if let selected = table.indexPathForSelectedRow {
            table.deselectRow(at: selected, animated: true)
        }
        
        //timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [unowned self] _ in self.manager?.update() })
        //timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tasks
    
    @objc func refresh() {
        manager = QueueManager(to: self)
        table.delegate = manager?.delegate
        table.dataSource = manager?.delegate
        table.reloadData()
        
        refreshcontrol.endRefreshing()
    }
    
    //MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "search": manager?.search(on: segue.destination)
        case "history": manager?.view(history: segue.destination)
        case "options":
            guard let vc = segue.destination as? OptionsTableViewController else { return }
            profilebar.options = vc
            profilebar.optionscontainer = options
        default: break
        }
    }
    

}
