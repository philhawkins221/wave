//
//  Playlist.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Playlist: Equatable, Codable, LibraryItem {
    let owner: String
    let id: String
    let library: String
    var name: String
    var social: Bool
    var songs: [Song]
    
    init(owner: String = "", id: String = "", library: String = "", name: String = "", social: Bool = true, songs: [Song] = []) {
        self.owner = owner
        self.id = id
        self.library = library
        self.name = name
        self.social = social
        self.songs = songs
    }
    
    static func ==(lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.id == rhs.id && lhs.library == rhs.library && lhs.owner == rhs.owner ? true : false
    }

}
