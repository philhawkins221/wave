//
//  SwipeController.swift
//  Clique
//
//  Created by Phil Hawkins on 12/9/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit
import SwipeableTabBarController

class SwipeController: SwipeableTabBarController {
    
    @IBInspectable var startindex: Int = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        setSwipeAnimation(type: SwipeAnimationType.none)
        
        let _ = Identity.sharedInstance()
        
        let _ = GeneralManager.sharedInstance()
        let _ = LibraryManager.sharedInstance()
        let _ = QueueManager.sharedInstance()
        
        guard
            let controllers = viewControllers,
            let _ = controllers[0] as? UINavigationController,
            (controllers[0] as! UINavigationController).viewControllers.count == 1,
            let lib = (controllers[0] as! UINavigationController).visibleViewController as? LibraryViewController,
            let np = controllers[1] as? NowPlayingViewController,
            let _ = controllers[2] as? UINavigationController,
            (controllers[2] as! UINavigationController).viewControllers.count == 1,
            let q = (controllers[2] as! UINavigationController).visibleViewController as? QueueViewController
            else { fatalError(ControllerError.wrongProvisioning.rawValue) }
        
        selectedViewController = controllers[startindex]
        let _ = q.view
        
        try! LibraryManager.manage(controller: lib)
        try! GeneralManager.manage(controller: np)
        try! QueueManager.manage(controller: q)
        
        try! GeneralManager.manage(user: Identity.sharedInstance().me)
        try! LibraryManager.manage(user: Identity.sharedInstance().me)
        try! QueueManager.manage(user: Identity.sharedInstance().me)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setSwipeAnimation(type: SwipeAnimationType.sideBySide)
    }
}
