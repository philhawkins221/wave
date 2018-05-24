//
//  Endpoints.swift
//  Clique
//
//  Created by Phil Hawkins on 1/1/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Endpoints {
    
    struct AppleMusic {
        static let storefronts: [String : String] = ["United States" : "us"]
        static let storefront = storefronts["United States"] ?? ""
        
        static let songpoint = { id in
            "https://api.music.apple.com/v1/catalog/" + storefront + "/songs/" + id
        }
        static let artistpoint = { id in
            "https://api.music.apple.com/v1/catalog/" + storefront + "/artists/" + id
        }
        static let albumpoint = { id in
            "https://api.music.apple.com/v1/catalog/" + storefront + "/albums/" + id
        }
        static let searchpoint = { (term: String) in
            "https://api.music.apple.com/v1/catalog/" + storefront + "/search?term=" + term.addingFormEncoding()! + "&types=songs,artists&limit=" + searchlimit.description
        }
        static let matchpoint = { (term: String) in
            "https://api.music.apple.com/v1/catalog/" + storefront + "/search?term=" + term.addingFormEncoding()! + "&types=songs&limit=1"
        }

    }
    
    struct Artwork {
        static let artpoint = { (song, artist) in
            "ws.audioscrobbler.com/2.0/?method=track.getInfo&track=" + song + "&artist=" + artist + "&api_key=826457ee44af558d7012efc826debf82&format=json"
        }
    }
    
    struct Spotify {
        static let markets: [String : String] = ["United States" : "us"]
        static let market = markets["United States"] ?? ""
        
        static let songpoint = { id in
            "https://api.spotify.com/v1/tracks/" + id + "&limit=" + searchlimit.description + "&market=" + market
        }
        
        struct artists {
            static let point = { id in
                "https://api.spotify.com/v1/artists/" + id
            }
            static let albumspoint = { id in
                point(id) + "/albums&limit=" + searchlimit.description + "&market=" + market
            }
            static let relatedartistspoint = { id in
                point(id) + "/related-artists&limit=" + searchlimit.description + "&market=" + market
            }
            static let topsongspoint = { id in
                point(id) + "/top-tracks&limit=" + searchlimit.description + "&market=" + market
            }
        }
        
        static let albumspoint = { id in
                "https://api.spotify.com/v1/albums/" + id + "/tracks&limit=" + searchlimit.description + "&market=" + market
        }
        static let searchpoint = { (term: String) in
            "https://api.spotify.com/v1/search?q=" + term.addingFormEncoding()! + "&type=track,artist&limit=" + searchlimit.description + "&market=" + market
        }
        static let matchpoint = { (term: String) in
            "https://api.spotify.com/v1/search?q=" + term.addingFormEncoding()! + "&type=track&limit=1&market=" + market
        }
    }
    
    struct Gracenote {
        static let recommendpoint = { (seeds: [Song]) -> String in
            var seedpoint = ""
            for seed in seeds { seedpoint += ("(text_artist_" + (seed.artist.name.addingFormEncoding() ?? "") + ");") }
            seedpoint.remove(at: seedpoint.indices.last!)
            
            return "https://c81551439.web.cddbp.net/webapi/json/1.0/radio/recommend?seed=" + seedpoint + "&return_count=" + searchlimit.description + "&max_tracks_per_artist=5&rotation=radio&user=" + gracenoteUserID + "&client=" + gracenoteClientID
            
        }
        static let registerpoint = "https://c81551439.web.cddbp.net/webapi/json/1.0/radio/register?client=" + gracenoteClientID
    }
    
    struct iTunes {
        static let countries: [String : String] = ["United States" : "us"]
        static let country = countries["United States"] ?? ""
        
        static let searchpoint = { (term: String) in
            "https://itunes.apple.com/search?term=" + term.addingFormEncoding()! + "&media=music&entity=song,musicArtist&isStreamable=true&limit=" + searchlimit.description + "&country=" + country
        }
        static let matchpoint = { (term: String) in
            "https://itunes.apple.com/search?term=" + term.addingFormEncoding()! + "&media=music&entity=song&limit=1&country=" + country
        }
        static let artistpoint = { id in
            "https://itunes.apple.com/lookup?id=" + id + "&entity=album&limit=" + searchlimit.description + "&country=" + country
        }
        static let albumpoint = { id in
            "https://itunes.apple.com/lookup?id=" + id + "&entity=song&limit=" + searchlimit.description + "&country=" + country
        }
        static let songspoint = { id in
            "https://itunes.apple.com/lookup?id=" + id + "&entity=song&limit=" + searchlimit.description + "&country=" + country
        }
    }
    
    struct Clique {
        static let newpoint = "http://clique2016.herokuapp.com/playlists/"
        static let findpoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id
        }
        static let searchpoint = "http://clique2016.herokuapp.com/playlists/search"
        static let allpoint = "http://clique2016.herokuapp.com/playlists/"
        
        static let playpoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id + "/play"
        }
        static let stoppoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id + "/stop"
        }
        static let listenpoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id + "/listen"
        }
        static let advancepoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id + "/advance"
        }
        static let votepoint = { (id: String, direction: Vote) -> String in
            switch direction {
            case .up: return "http://clique2016.herokuapp.com/playlists/" + id + "/upvote"
            case .down: return "http://clique2016.herokuapp.com/playlists/" + id + "/downvote"
            }
        }
        
        struct add {
            static let songpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/queue"
            }
            static let friendpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/add-friend"
            }
            static let listenerpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/add-listener"
            }
        }
        
        struct request {
            static let friendpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/request-friend"
            }
            static let songpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/request-song"
            }
        }
        
        struct update {
            static let userpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id
            }
            static let queuepoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-queue"
            }
            static let librarypoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-library"
            }
            static let playlistpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-playlist"
            }
            static let applemusicpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-applemusic"
            }
            static let spotifypoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-spotify"
            }
            static let usernamepoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-username"
            }
            static let votingpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-voting"
            }
            static let listenerspoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-listeners"
            }
            static let requestspoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-requests"
            }
            static let songrequestspoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/update-song-requests"
            }
        }
        
        struct delete {
            static let userpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id
            }
            static let playlistpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/delete-playlist"
            }
            static let friendpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/delete-friend"
            }
        }
    }
    
}
