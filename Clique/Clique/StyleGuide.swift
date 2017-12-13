//
//  StyleGuide.swift
//  Clique
//
//  Created by Phil Hawkins on 12/10/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

protocol StyleGuide {
    associatedtype controller
    static func enforce(on controller: controller)
}

struct NavigationControllerStyleGuide: StyleGuide {
    
    static func enforce(on controller: UINavigationController?) {
        if #available(iOS 8.2, *) {
            controller?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)
            ]
        } else {
            controller?.navigationBar.titleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        }
    }
}

struct TabBarControllerStyleGuide: StyleGuide {
    
    static func enforce(on controller: UITabBarController?) {
        controller?.tabBar.isHidden = true
    }
}

//TODO: - table header style guide -- requires utility
struct TableHeaderStyleGuide: StyleGuide {
    
    static func enforce(on controller: UITableViewHeaderFooterView) {
        <#code#>
    }
}
