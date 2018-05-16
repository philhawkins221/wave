//
//  Single.swift
//  Clique
//
//  Created by Phil Hawkins on 5/15/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Single: Equatable {
    
    let title: String
    let artist: String
    
    var info: Song {
        return Song(
            id: "",
            library: "",
            title: title,
            artist: Artist(
                id: "",
                library: "",
                name: artist
            ),
            sender: "1",
            artwork: "",
            votes: 0
        )
    }
    
}
