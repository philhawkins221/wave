//
//  SpotifyAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct SpotifyAPI: Searching {
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.Spotify.searchpoint(term)
        
        if let response = Web.call(.get, to: endpoint, token: Spotify.authorization) {
            print("spotify api search response", response)
            let songs = response["tracks"]["items"].array ?? []
            let artists = response["artists"]["items"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["uri"].string ?? "",
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
            
            for artist in artists {
                results.append(Artist(
                    id: artist["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    name: artist["name"].string ?? ""
                ))
            }
        }
        
        return results
    }
    
    static func match(_ song: Song) -> Song? {
        let term = song.artist.name + " " + song.title
        let endpoint = Endpoints.Spotify.matchpoint(term)
        
        if let response = Web.call(.get, to: endpoint, token: Spotify.authorization),
           let match = response["tracks"]["items"].array?.first {
            print(match)
            return Song(
                id: match["uri"].string ?? "",
                library: Catalogues.Spotify.rawValue,
                title: match["name"].string ?? "",
                artist: Artist(
                    id: match["artists"][0]["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    name: match["artists"][0]["name"].string ?? ""),
                sender: "",
                artwork: match["album"]["images"][0]["url"].string ?? "",
                votes: 0
            )
        }
        
        return nil
    }
    
    static func get(albums artist: Artist) -> [Album] {
        let endpoint = Endpoints.Spotify.artists.albumspoint(artist.id)
        var results = [Album]()
        
        if let response = Web.call(.get, to: endpoint, with: nil, token: Spotify.authorization) {
            let albums = response["items"].array ?? []
            
            for album in albums {
                var year = ""
                if let date = album["releaseDate"].string {
                    let i = date.index(date.startIndex, offsetBy: 4)
                    year = String(date[..<i])
                }
                results.append(Album(
                    id: album["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    name: album["name"].string ?? "",
                    artwork: album["images"][0]["url"].string ?? "",
                    year: year
                ))
            }
        }
        
        return results
    }
    
    static func get(songs album: Album) -> [Song] {
        let endpoint = Endpoints.Spotify.albumspoint(album.id)
        var result = [Song]()
        
        if let response = Web.call(.get, to: endpoint, with: nil, token: Spotify.authorization) {
            let songs = response["tracks"]["items"].array ?? []
            
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
        
        if let response = Web.call(.get, to: endpoint, with: nil, token: Spotify.authorization) {
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
        
        if let response = Web.call(.get, to: endpoint, with: nil, token: Spotify.authorization) {
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
