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
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var historybutton: UIBarButtonItem!
    @IBOutlet weak var addbutton: UIBarButtonItem!
    
    //MARK: - properties
    
    var manager: QueueManager?
    var timer = Timer()
    
    //MARK: - lifecycle stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = QueueManager(to: self)
        table.delegate = manager?.delegate
        table.dataSource = manager?.delegate
                
        //TODO: timer and notifications
        //NotificationCenter.default.addObserver(self, selector: #selector(self.advance), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationControllerStyleGuide.enforce(on: navigationController)
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        if let selected = table.indexPathForSelectedRow {
            table.deselectRow(at: selected, animated: true)
        }
        
        if manager?.client().me() ?? false {
            table.setEditing(true, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manager?.update()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [unowned self] _ in self.manager?.update() })
        //timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //TODO: fix timer invalidate -- view is not disappearing
        timer.invalidate()
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
