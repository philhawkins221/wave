//
//  SpotifyAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct SpotifyAPI: Searching {
    //TODO: fix tf out of search
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.AppleMusic.searchpoint(term)
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let songs = response["tracks"]["items"].array ?? []
            let artists = response["artists"]["items"].array ?? []
            
            for song in songs {
                results.append( Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: Artist(
                        id: song["artists"][0]["id"].string ?? "",
                        library: Catalogues.Spotify.rawValue,
                        name: song["attributes"]["artistName"].string ?? ""),
                    sender: "",
                    artwork: song["attributes"]["artwork"]["url"].string ?? "",
                    votes: 0
                ))
            }
            
            for artist in artists {
                results.append(Artist(
                    id: artist["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    name: artist["name"].string ?? ""))
            }
        }
        
        return results
    }
    
    //TODO: spotify match
    static func match(_ song: Song) -> Song? {
        return nil
    }
    
    static func get(albums artist: Artist) -> [Album] {
        let endpoint = Endpoints.Spotify.artists.albumspoint(artist.id)
        var results = [Album]()
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let albums = response["items"].array ?? []
            
            for album in albums {
                results.append(Album(
                    id: album["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    name: album["name"].string ?? "",
                    artwork: album["images"][0]["url"].string ?? ""))
            }
        }
        
        return results
    }
    
    static func get(songs album: Album) -> [Song] {
        let endpoint = Endpoints.Spotify.albums.songspoint(album.id)
        var result = [Song]()
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let songs = response["items"].array ?? []
            
            for song in songs {
                result.append(
                    Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    title: song["name"].string ?? "",
                    artist: Artist(
                        id: song["artists"]["id"].string ?? "",
                        library: Catalogues.Spotify.rawValue,
                        name: song["artists"][0]["name"].string ?? ""),
                    sender: "",
                    artwork: album.artwork,
                    votes: 0
                ))
            }
        }
        
        return result
    }
    
    static func get(related artist: Artist) -> [Artist] {
        let endpoint = Endpoints.Spotify.artists.relatedartistspoint(artist.id)
        var results = [Artist]()
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let artists = response["artists"].array ?? []
            
            for artist in artists {
                results.append(Artist(
                    id: artist["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    name: artist["name"].string ?? ""))
            }
        }
        
        return results
    }
    
    static func get(top artist: Artist) -> [Song] {
        let endpoint = Endpoints.Spotify.artists.topsongspoint(artist.id)
        var results = [Song]()
        
        if let response = Web.call(.get, to: endpoint, with: nil) {
            let songs = response["tracks"].array ?? []
            
            for song in songs {
                results.append(
                    Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    title: song["name"].string ?? "",
                    artist: Artist(
                        id: song["artists"][0]["id"].string ?? "",
                        library: Catalogues.Spotify.rawValue,
                        name: song["artists"][0]["name"].string ?? ""),
                    sender: "",
                    artwork: song["album"]["images"][0]["url"].string ?? "",
                    votes: 0
                ))
            }
        }
        
        return results
    }
}
