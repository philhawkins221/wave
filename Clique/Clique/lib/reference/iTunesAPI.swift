//
//  iTunesAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct iTunesAPI {
    static func match(_ song: Song) -> Song? {
        
        let term = song.artist.name + " " + song.title
        let endpoint = Endpoints.iTunes.searchpoint(term)
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let match = response["results"].array?.first ?? []
            return Song(
                id: song.id,
                library: Catalogues.Library.rawValue,
                title: match["trackName"].string ?? "",
                artist: Artist(
                    id: "",
                    library: Catalogues.Library.rawValue,
                    name: match["artistName"].string ?? ""),
                artwork: match["artworkUrl60"].string ?? "",
                votes: 0)
        }
        
        return nil
    }
}
