//
//  iTunesAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct iTunesAPI: Searching {
    
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.iTunes.searchpoint(term)
        
        if let response = Web.call(.get, to: endpoint) {
            let findings = response["results"].array ?? []
            
            for item in findings {
                switch item["wrapperType"].string ?? "" {
                case "track":
                    results.append(Song(
                        id: (item["trackId"].int ?? 0).description,
                        library: Catalogues.AppleMusic.rawValue,
                        title: item["trackName"].string ?? "",
                        artist: Artist(
                            id: (item["artistId"].int ?? 0).description,
                            library: Catalogues.AppleMusic.rawValue,
                            name: item["artistName"].string ?? ""
                        ),
                        sender: "",
                        artwork: item["artworkUrl100"].string ?? "",
                        votes: 0
                    ))
                case "artist":
                    results.append(Artist(
                        id: (item["artistId"].int ?? 0).description,
                        library: Catalogues.AppleMusic.rawValue,
                        name: item["artistName"].string ?? ""
                    ))
                default: break
                }
            }
        }
        
        return results
    }
    
    static func match(_ song: Song) -> Song? {
        let term = song.artist.name + " " + song.title
        let endpoint = Endpoints.iTunes.matchpoint(term)
        
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
                sender: song.sender,
                artwork: match["artworkUrl100"].string ?? "",
                votes: 0
            )
        }
        
        return nil
    }
    
    static func get(songs artist: Artist) -> [Song] {
        let endpoint = Endpoints.iTunes.songspoint(artist.id)
        var results = [Song]()
        
        if let response = Web.call(.get, to: endpoint) {
            let findings = response["results"].array ?? []
            
            for item in findings {
                switch item["wrapperType"].string ?? "" {
                case "track":
                    results.append(Song(
                        id: (item["trackId"].int ?? 0).description,
                        library: Catalogues.AppleMusic.rawValue,
                        title: item["trackName"].string ?? "",
                        artist: Artist(
                            id: (item["artistId"].int ?? 0).description,
                            library: Catalogues.AppleMusic.rawValue,
                            name: item["artistName"].string ?? ""
                        ),
                        sender: "",
                        artwork: item["artworkUrl100"].string ?? "",
                        votes: 0
                    ))
                default: break
                }
            }
        }
        
        return results
    }
    
    static func get(albums artist: Artist) -> [Album] {
        let endpoint = Endpoints.iTunes.artistpoint(artist.id)
        var results = [Album]()
        
        if let response = Web.call(.get, to: endpoint) {
            let findings = response["results"].array ?? []
            
            for item in findings {
                switch item["wrapperType"].string ?? "" {
                case "collection":
                    var year = ""
                    if let date = item["releaseDate"].string {
                        let i = date.index(date.startIndex, offsetBy: 4)
                        year = String(date[..<i])
                    }
                    results.append(Album(
                        id: (item["collectionId"].int ?? 0).description,
                        library: Catalogues.AppleMusic.rawValue,
                        name: item["collectionName"].string ?? "",
                        artwork: item["artworkUrl100"].string ?? "",
                        year: year
                    ))
                default: break
                }
            }
        }
        
        return results
    }
    
    static func get(songs album: Album) -> [Song] {
        let endpoint = Endpoints.iTunes.albumpoint(album.id)
        var results = [Song]()
        
        if let response = Web.call(.get, to: endpoint) {
            let findings = response["results"].array ?? []
            
            for item in findings {
                switch item["wrapperType"].string ?? "" {
                case "track":
                    results.append(Song(
                        id: (item["trackId"].int ?? 0).description,
                        library: Catalogues.AppleMusic.rawValue,
                        title: item["trackName"].string ?? "",
                        artist: Artist(
                            id: (item["artistId"].int ?? 0).description,
                            library: Catalogues.AppleMusic.rawValue,
                            name: item["artistName"].string ?? ""
                        ),
                        sender: "",
                        artwork: item["artworkUrl100"].string ?? "",
                        votes: 0
                    ))
                default: break
                }
            }
        }
        
        return results
    }
    
}
