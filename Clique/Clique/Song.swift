//
//  Song.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

struct Song: Equatable, Codable {
    
    let id: String
    let library: String
    let title: String
    let artist: String
    //let album: String
    let artwork: String
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        if lhs.id == rhs.id && lhs.library == rhs.library {
            return true
        }
        
        return false
    }
    
}
