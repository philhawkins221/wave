//
//  Song.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation

protocol CatalogItem {}
protocol LibraryItem {}

struct Song: Equatable, Codable, CatalogItem, LibraryItem {
    
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

struct Playlist: Equatable, Codable, LibraryItem {
    let owner: String
    let id: String
    let library: String
    var name: String
    var social: Bool
    var songs: [Song]
    
    static func ==(lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.id == rhs.id && lhs.library == rhs.library ? true : false
    }
}

struct Artist: Codable, CatalogItem, LibraryItem {
    let id: String
    let library: String
    let name: String
}

struct Album: CatalogItem {
    let id: String
    let library: String
    let name: String
    let artwork: String
}
