//
//  Queue.swift
//  Clique
//
//  Created by Phil Hawkins on 1/2/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Queue: Codable {
    var radio: Bool
    var voting: Bool
    var requestsonly: Bool
    var donotdisturb: Bool
    
    var queue: [Song]
    var history: [Song]
    var current: Song?
    
    var listeners: [String]
    
    init() {
        radio = false
        voting = false
        requestsonly = false
        donotdisturb = false
        
        queue = []
        history = []
        
        listeners = []
    }
}
