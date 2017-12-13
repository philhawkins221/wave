//
//  SwipeController.swift
//  Clique
//
//  Created by Phil Hawkins on 12/9/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit
//import EZSwipeController
import SwipeableTabBarController

class SwipeController: SwipeableTabBarController {
    
    @IBInspectable var startindex: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSwipeAnimation(type: SwipeAnimationType.none)
        
        if let controllers = viewControllers {
            selectedViewController = controllers[startindex]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setSwipeAnimation(type: SwipeAnimationType.sideBySide)
    }
}
