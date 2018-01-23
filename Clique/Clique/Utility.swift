//
//  Utility.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_Synchronous
import AlamofireImage
import SwiftyJSON

//MARK: - protocols

protocol Searching {
    static func search(_ term: String) -> [CatalogItem] //[Any]
    //static func find(id: String) -> Song?
}

//MARK: - utilities

struct WebUtility {
    
    static func call(_ type: RequestMethod, to endpoint: String, with parameters: [String : Any]?) -> JSON? {
        
        print("calling", type.rawValue, "request to endpoint", endpoint)
        
        let method: HTTPMethod
        switch type {
        case .get: method = .get
        case .put: method = .put
        case .post: method = .post
        case .delete: method = .delete
        }
        
        var response: JSON? = nil
        
        let res = Alamofire.request(endpoint, method: method, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: nil).responseJSON()
        
        if let value = res.result.value {
            response = JSON(value)
        }
        
        print(response as Any)
        
        return response
    }
    
    static func send(_ type: RequestMethod, to endpoint: String, with parameters: [String : Any]?) {
        
        print("sending", type.rawValue, "request to endpoint", endpoint)
        
        let method: HTTPMethod
        switch type {
        case .get: method = .get
        case .put: method = .put
        case .post: method = .post
        case .delete: method = .delete
        }
        
        Alamofire.request(endpoint, method: method, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: nil).validate()
    }
    
    static func parameterize(song: Song) -> [String : Any] {
        return [
            "id": song.id,
            "library": song.library,
            "title": song.title,
            "artist": song.artist,
            "artwork": song.artwork,
            "votes": song.votes
        ]
    }
    
    static func parameterize(queue: Queue) -> [String : Any] {
        return [
            "radio": queue.radio,
            "voting": queue.voting,
            "requestsonly": queue.requestsonly,
            "donotdisturb": queue.donotdisturb,
            
            "queue": queue.queue.map { parameterize(song: $0) },
            "history": queue.history.map { parameterize(song: $0) },
            "current": (queue.current != nil ? parameterize(song: queue.current!) : nil) as Any,
            
            "listeners": queue.listeners
        ]
    }
    
    static func parameterize(playlist: Playlist) -> [String : Any] {
        return [
            "owner": playlist.owner,
            "id": playlist.id,
            "library": playlist.library,
            "name": playlist.name,
            "social": playlist.social,
            "songs": playlist.songs.map { parameterize(song: $0) }
        ]
    }
    
    static func parameterize(user: User) -> [String : Any] {
        return [
            "username": user.username,
            "id": user.id,
            "queue": parameterize(queue: user.queue),
            "library": user.library.map { parameterize(playlist: $0) },
            "applemusic": user.applemusic,
            "spotify": user.spotify
        ]
    }
    
    static func get(image url: String) -> UIImageView? {
        guard let location = URL(string: url) else { return nil }
        let placeholder = UIImage(named: "genericart.png")
        
        let image = UIImageView()
        image.af_setImage(withURL: location, placeholderImage: placeholder)
        
        return image
    }
    
}

struct AppleMusicAPIUtility: Searching {
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.AppleMusic.searchpoint(term)
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let songs = response["results"]["songs"]["data"].array ?? []
            let artists = response["results"]["artists"]["data"].array ?? []
            
            for artist in artists {
                results.append(Artist(
                    id: artist["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    name: artist["attributes"]["name"].string ?? ""))
            }
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: Artist(
                        id: results.first is Artist ? (results.first as? Artist)?.id ?? "" : "",
                        library: Catalogues.AppleMusic.rawValue,
                        name: song["attributes"]["artistName"].string ?? ""),
                    artwork: song["attributes"]["artwork"]["url"].string ?? "",
                    votes: 0)
                )
            }
    
        }
        
        return results
    }
    
    static func match(_ song: Song) -> Song? {
        
        let term = song.artist.name + " " + song.title
        let endpoint = Endpoints.AppleMusic.matchpoint(term)
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let match = response["results"]["songs"].array?.first ?? []
            return Song(
                id: match["id"].string ?? "",
                library: Catalogues.AppleMusic.rawValue,
                title: match["attributes"]["name"].string ?? "",
                artist: Artist(id: match["relationships"]["artists"]["data"][0]["id"].string ?? "",
                               library: Catalogues.AppleMusic.rawValue,
                               name: match["attributes"]["artistName"].string ?? ""),
                artwork: match["attributes"]["artwork"]["url"].string ?? "",
                votes: 0)
        }
        
        return nil
    }
    
    static func get(albums artist: Artist) -> [Album] {
        let endpoint = Endpoints.AppleMusic.artistpoint(artist.id)
        var results = [Album]()
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let albums = response["data"][0]["relationships"]["albums"]["data"].array ?? []
            
            var artwork = ""
            
            if let id = albums.first?["id"].string {
                let ep = Endpoints.AppleMusic.albumpoint(id)
                if let res = WebUtility.call(.get, to: ep, with: nil) {
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
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let songs = response["data"][0]["relationships"]["tracks"]["data"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: Artist(id: song["relationships"]["artists"]["data"][0]["id"].string ?? "",
                                   library: Catalogues.AppleMusic.rawValue,
                                   name: song["attributes"]["artistName"].string ?? ""),
                    artwork: song["attributes"]["artwork"]["url"].string ?? "",
                    votes: 0))
            }
        }
        
        return results
    }
    
    static func find(id: String) -> Song? {
        let endpoint = Endpoints.AppleMusic.songpoint(id)
        
        check: if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            guard let song = response["data"].array?[0] else { break check }
            
            return Song(
                id: song["id"].string ?? "",
                library: Catalogues.AppleMusic.rawValue,
                title: song["attributes"]["name"].string ?? "",
                artist: Artist(
                    id: "",
                    library: "",
                    name: song["attributes"]["artistName"].string ?? ""),
                artwork: song["attributes"]["artwork"]["url"].string ?? "",
                votes: 0)
        }
        
        return nil
    }

}

struct SpotifyAPIUtility: Searching {
    //TODO: fix tf out of search
    static func search(_ term: String) -> [CatalogItem] {
        var results = [CatalogItem]()
        let endpoint = Endpoints.AppleMusic.searchpoint(term)
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let songs = response["tracks"]["items"].array ?? []
            let artists = response["artists"]["items"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.AppleMusic.rawValue,
                    title: song["attributes"]["name"].string ?? "",
                    artist: Artist(
                        id: song["artists"][0]["id"].string ?? "",
                        library: Catalogues.Spotify.rawValue,
                        name: song["attributes"]["artistName"].string ?? ""),
                    artwork: song["attributes"]["artwork"]["url"].string ?? "",
                    votes: 0)
                )
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
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
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
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let songs = response["items"].array ?? []
            
            for song in songs {
                result.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    title: song["name"].string ?? "",
                    artist: Artist(
                        id: song["artists"]["id"].string ?? "",
                        library: Catalogues.Spotify.rawValue,
                        name: song["artists"][0]["name"].string ?? ""),
                    artwork: album.artwork,
                    votes: 0))
            }
        }
        
        return result
    }
    
    static func get(relatedartists artist: Artist) -> [Artist] {
        let endpoint = Endpoints.Spotify.artists.relatedartistspoint(artist.id)
        var results = [Artist]()
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
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
    
    static func get(topsongs artist: Artist) -> [Song] {
        let endpoint = Endpoints.Spotify.artists.topsongspoint(artist.id)
        var results = [Song]()
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let songs = response["tracks"].array ?? []
            
            for song in songs {
                results.append(Song(
                    id: song["id"].string ?? "",
                    library: Catalogues.Spotify.rawValue,
                    title: song["name"].string ?? "",
                    artist: Artist(
                        id: song["artists"][0]["id"].string ?? "",
                        library: Catalogues.Spotify.rawValue,
                        name: song["artists"][0]["name"].string ?? ""),
                    artwork: song["album"]["images"][0]["url"].string ?? "",
                    votes: 0))
            }
        }
        
        return results
    }
}

struct iTunesAPIUtility {
    static func match(_ song: Song) -> Song? {
        
        let term = song.artist.name + " " + song.title
        let endpoint = Endpoints.iTunes.searchpoint(term)
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
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

struct CliqueAPIUtility {
    
    static func find(user id: String) -> User? {
        let endpoint = Endpoints.Clique.findpoint(id)
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            return try? JSONDecoder().decode(User.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func search(user username: String) -> [User] {
        var results = [User]()
        let endpoint = Endpoints.Clique.searchpoint
        
        if let response = WebUtility.call(.get, to: endpoint, with: nil) {
            let users = response.array ?? []
            for user in users {
                if let result = try? JSONDecoder().decode(User.self, from: user.rawData()) {
                    if result.username == username {
                        results.append(result)
                    }
                }
            }
        }
        
        return results
    }
    
    static func add(song: Song, to user: User?) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }
        
        let endpoint = Endpoints.Clique.addpoint(user.id)
        let parameters = WebUtility.parameterize(song: song)
        
        let _ = WebUtility.call(.get, to: endpoint, with: parameters)
    }
    
    static func advance(queue user: User?) -> Song? {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }

        let endpoint = Endpoints.Clique.advancepoint(user.id)
        
        if let response = WebUtility.call(.put, to: endpoint, with: nil) {
            return try? JSONDecoder().decode(Song.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func vote(song: Song, _ direction: Vote, for user: User?) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }

        let endpoint = Endpoints.Clique.votepoint(user.id, direction)
        let parameters = WebUtility.parameterize(song: song)
        
        let _ = WebUtility.call(.post, to: endpoint, with: parameters)
    }
    
    static func update(user replacement: User?) {
        guard let replacement = replacement else {
            fatalError(ManagementError.unidentifiedUser.rawValue)
        }
        
        let endpoint = Endpoints.Clique.update.userpoint(replacement.id)
        let parameters = WebUtility.parameterize(user: replacement)
        
        let _ = WebUtility.call(.put, to: endpoint, with: parameters)
    }
    
    static func update(queue user: User?, with replacement: Queue) {
        guard let user = user else {
            fatalError(ManagementError.unidentifiedUser.rawValue)
        }

        let endpoint = Endpoints.Clique.update.queuepoint(user.id)
        let parameters = WebUtility.parameterize(queue: replacement)
        
        let _ = WebUtility.call(.post, to: endpoint, with: parameters)
    }
    
    static func update(library user: User?, with replacement: [Playlist]) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }

        let endpoint = Endpoints.Clique.update.librarypoint(user.id)
        let parameters: [String : Any] = ["library": replacement.map { WebUtility.parameterize(playlist: $0) }]
        
        let _ = WebUtility.call(.put, to: endpoint, with: parameters)
    }
    
    static func new(user: User) -> User? {
        let endpoint = Endpoints.Clique.newpoint
        let parameters = WebUtility.parameterize(user: user)
        
        if let response = WebUtility.call(.post, to: endpoint, with: parameters) {
            return try? JSONDecoder().decode(User.self, from: response.rawData())
        }
        
        return nil
    }
    
    static func delete(user: User?) {
        guard let user = user else { fatalError(ManagementError.unidentifiedUser.rawValue) }

        let endpoint = Endpoints.Clique.deletepoint(user.id)
        
        let _ = WebUtility.call(.delete, to: endpoint, with: nil)
    }

}

struct AlertsUtility {
    static func textField(title: String? = nil, message: String? = nil, entry: String? = nil, action: ((_ action: UIAlertAction, _ controller: UIAlertController) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { $0.text = entry }
        
        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { act in
            action?(act, alert)
        })
        
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    static func confirmation(title: String? = nil, message: String? = nil, entry: String? = nil, action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { action?($0) })
        
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
}

struct DefaultsUtility {
    //bool: synced playlists
    //last sync date
    
    //identity values
    //personal id
    //friends
}
