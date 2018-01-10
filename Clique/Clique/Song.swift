//
//  Song.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

protocol CatalogItem {}

struct Song: Equatable, Codable, CatalogItem {
    
    let id: String
    let library: String
    let title: String
    let artist: Artist
    //let album: String
    var artwork: String
    var votes: Int
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        if lhs.id == rhs.id && lhs.library == rhs.library {
            return true
        }
        
        return false
    }
    
}

struct Artist: Codable, CatalogItem {
    let id: String
    let library: String
    let name: String
}

struct Album: CatalogItem {
    let id: String
    let name: String
    let artwork: String
}
