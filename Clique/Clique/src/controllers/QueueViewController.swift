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
    @IBOutlet weak var optionscover: UIView!
    
    @IBOutlet weak var table: UITableView?
    @IBOutlet weak var historybutton: UIBarButtonItem!
    @IBOutlet weak var addbutton: UIBarButtonItem!
    
    //MARK: - properties
    
    lazy var manager: QueueManager? = wave()
    
    var mode: QueueMode = .queue
    var user = Identity.me
    var fill: Playlist?
    var edit = false
    var shuffled: Playlist?
    var radio = [Single]()
    var listeners = [String : String]()
    
    let refreshcontrol = UIRefreshControl()
    weak var timer = Timer()
    
    //MARK: - lifecycle stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refresh()
                        
        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        table?.tintColor = UIColor.orange
        table?.canCancelContentTouches = false
        
        profilebar?.controller = self
        
        refreshcontrol.addTarget(self, action: #selector(manualRefresh), for: .valueChanged)
        refreshcontrol.attributedTitle = NSAttributedString(string: "pull to refresh")
        
        if #available(iOS 10.0, *) {
            table?.refreshControl = refreshcontrol
        } else {
            table?.backgroundView = refreshcontrol
        }
                
        //TODO: notifications
        //NotificationCenter.default.addObserver(self, selector: #selector(self.advance), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        table?.setEditing(
            (manager?.client().me() ?? false) || !(manager?.client().queue.requestsonly ?? true),
            animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        swipe?.setDiagonalSwipe(enabled: false)
        
        refresh()
        
        if let selected = table?.indexPathForSelectedRow {
            table?.deselectRow(at: selected, animated: true)
        }
        
        timer?.invalidate()
        timer = mode == .queue ? Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [unowned self] _ in self.refresh() } : nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        edit = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tasks
    
    @objc func manualRefresh() {
        edit = false
        refresh()
    }
    
    @objc func refresh() {
        setTabBarSwipe(enabled: !edit)
        
        manager = QueueManager(to: self)
        table?.delegate = manager?.delegate
        table?.dataSource = manager?.delegate
        table?.reloadData()
                
        refreshcontrol.endRefreshing()
        gm?.refresh()
        
        table?.isHidden = false
    }
    
    func wave() -> QueueManager? {
        let manager = QueueManager(to: q)
        return manager
    }
    
    //MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "search": manager?.search(on: segue.destination)
        case "history": manager?.view(history: segue.destination)
        case "options":
            guard let vc = segue.destination as? OptionsTableViewController else { return }
            profilebar?.options = vc
            profilebar?.optionscontainer = options
            profilebar?.optionscover = optionscover
            vc.profilebar = profilebar
        default: break
        }
    }
    

}
