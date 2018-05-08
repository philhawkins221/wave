//
//  Queue.swift
//  Clique
//
//  Created by Phil Hawkins on 1/2/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Queue: Codable {
    var owner: String
    var listeners: [String]
    
    var radio: Bool
    var voting: Bool
    var requestsonly: Bool
    var donotdisturb: Bool
    
    var queue: [Song]
    var history: [Song]
    var requests: [Song]
    var current: Song?
    
    init() {
        owner = ""
        listeners = []
        
        radio = false
        voting = false
        requestsonly = false
        donotdisturb = false
        
        queue = []
        history = []
        requests = []
    }
}
