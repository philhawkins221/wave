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

/*
class SwipeController: EZSwipeController, EZSwipeControllerDataSource {
    
    let lib = LibraryViewController()
    let np = NowPlayingViewController()
    let q = QueueViewController()
    
    //MARK: lifecycle methods
    
    override func setupView() {
        super.setupView()
        
        //navigationBarShouldNotExist = true
        datasource = self
    }
    
    //MARK: swipe protocol methods
    
    func viewControllerData() -> [UIViewController] {
        return [lib, np, q]
    }
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    func titlesForPages() -> [String] {
        return ["Library", "Now Playing", "Queue"]
    }
    
    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
        let bar = UINavigationBar()
        bar.barTintColor = UIColor.orange
        
        if #available(iOS 8.2, *) {
            bar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
            ]
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        }
        
        var title = ""
        
        switch index {
        case 0: title = "Library"
        case 1: title = "Now Playing"
        case 2: title = "Queue"
        default: title = ""
        }
        
        let item = UINavigationItem(title: title)
        item.hidesBackButton = true
        
        bar.pushItem(item, animated: false)
        return bar
    }
    
    func changedToPageIndex(_ index: Int) {
        print(index)
    }
 

}
*/
