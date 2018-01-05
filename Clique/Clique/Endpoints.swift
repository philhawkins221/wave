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
        static let searchpoint = { (term: String) in
            "https://api.music.apple.com/v1/catalog/" + storefront + "/search?term=" + term.addingFormEncoding()! + "&types=songs,artists&limit=" + searchlimit.description
        }

    }
    
    struct Spotify {
        static let markets: [String : String] = ["United States" : "us"]
        static let market = markets["United States"] ?? ""
        
        static let songpoint = ""
        static let artistpoint = ""
        static let searchpoint = { (term: String) in
            "https://api.spotify.com/v1/search?q=" + term.addingFormEncoding()! + "&type=track,artist&limit=" + searchlimit.description + "&market=" + market
        }
    }
    
    struct iTunes {
        static let countries: [String : String] = ["United States" : "us"]
        static let country = countries["United States"] ?? ""
        
        static let searchpoint = { (term: String) in
            "https://itunes.apple.com/search?term=" + term.addingFormEncoding()! + "&media=music&entity=musicTrack,musicArtist&limit=1&country=" + country
        }
    }
    
    struct Clique {
        static let findpoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id
        }
        static let searchpoint = "http://clique2016.herokuapp.com/playlists"
        
        struct update {
            static let queuepoint = { id in
                 "http://clique2016.herokuapp.com/playlists/" + id + "/updateClique"
            }
            
            static let librarypoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/loadSongs"
            }
        }
    }
}
