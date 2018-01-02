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
        
        static let songpoint = "https://api.music.apple.com/v1/catalog/" + storefront + "/songs/"
        static let artistpoint = "https://api.music.apple.com/v1/catalog/" + storefront + "/artists/"
        static let searchpoint = "https://api.music.apple.com/v1/catalog/" + storefront + "/search?term="
        static let searchparameters = "&types=songs&limit=25"
    }
    
    struct Spotify {
        
    }
    
    struct iTunes {
        
    }
    
    struct Clique {
        
    }
}
