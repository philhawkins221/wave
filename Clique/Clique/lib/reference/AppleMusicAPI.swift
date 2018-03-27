//
//  AppleMusicAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct AppleMusicAPI: Searching {
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.AppleMusic.searchpoint(term)
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let songs = response["results"]["songs"]["data"].array ?? []
            let artists = response["results"]["artists"]["data"].array ?? []
            
            for artist in artists {
                results.append(Artist(
                    id: artist["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    name: artist["attributes"]["name"].string ?? ""))
            }
            
            for song in songs {
                results.append(
                    Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: Artist(
                        id: results.first is Artist ? (results.first as? Artist)?.id ?? "" : "",
                        library: Catalogues.AppleMusic.rawValue,
                        name: song["attributes"]["artistName"].string ?? ""),
                    sender: "",
                    artwork: song["attributes"]["artwork"]["url"].string ?? "",
                    votes: 0
                ))
            }
            
        }
        
        return results
    }
    
    static func match(_ song: Song) -> Song? {
        
        let term = song.artist.name + " " + song.title
        let endpoint = Endpoints.AppleMusic.matchpoint(term)
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let match = response["results"]["songs"].array?.first ?? []
            return Song(
                id: match["id"].string ?? "",
                library: Catalogues.AppleMusic.rawValue,
                title: match["attributes"]["name"].string ?? "",
                artist: Artist(id: match["relationships"]["artists"]["data"][0]["id"].string ?? "",
                               library: Catalogues.AppleMusic.rawValue,
                               name: match["attributes"]["artistName"].string ?? ""),
                sender: song.sender,
                artwork: match["attributes"]["artwork"]["url"].string ?? "",
                votes: 0
            )
        }
        
        return nil
    }
    
    static func get(albums artist: Artist) -> [Album] {
        let endpoint = Endpoints.AppleMusic.artistpoint(artist.id)
        var results = [Album]()
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let albums = response["data"][0]["relationships"]["albums"]["data"].array ?? []
            
            var artwork = ""
            
            if let id = albums.first?["id"].string {
                let ep = Endpoints.AppleMusic.albumpoint(id)
                if let res = Web.call(.get, to: ep, with: nil) {
                    artwork = res["data"][0]["attributes"]["artwork"]["url"].string ?? ""
                }
            }
            
            for album in albums {
                results.append(Album(
                    id: album["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    name: "",
                    artwork: artwork))
            }
        }
        
        return results
    }
    
    static func get(songs album: Album) -> [Song] {
        let endpoint = Endpoints.AppleMusic.albumpoint(album.id)
        var results = [Song]()
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let songs = response["data"][0]["relationships"]["tracks"]["data"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: Artist(id: song["relationships"]["artists"]["data"][0]["id"].string ?? "",
                                   library: Catalogues.AppleMusic.rawValue,
                                   name: song["attributes"]["artistName"].string ?? ""),
                    sender: "",
                    artwork: song["attributes"]["artwork"]["url"].string ?? "",
                    votes: 0
                ))
            }
        }
        
        return results
    }
    
    static func find(id: String) -> Song? {
        let endpoint = Endpoints.AppleMusic.songpoint(id)
        
        check: if let response = Web.call(.get, to: endpoint, with: nil) {
            guard let song = response["data"].array?[0] else { break check }
            
            return Song(
                id: song["id"].string ?? "",
                library: Catalogues.AppleMusic.rawValue,
                title: song["attributes"]["name"].string ?? "",
                artist: Artist(
                    id: "",
                    library: "",
                    name: song["attributes"]["artistName"].string ?? ""),
                sender: "",
                artwork: song["attributes"]["artwork"]["url"].string ?? "",
                votes: 0
            )
        }
        
        return nil
    }
    
}
