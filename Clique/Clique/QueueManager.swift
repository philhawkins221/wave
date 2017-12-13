//
//  QueueManager.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

struct QueueManager {
    
    static var instance: QueueManager?
    var queue: [Song]
    var table: UITableView
    var delegate: QueueDelegate
    
    static func sharedInstance() -> QueueManager {
        
        if instance == nil {
			instance = QueueManager()
		}
		
        return instance!
    }
    
    private init() {
        //TODO: - populate with music player queue
        
    }
}
