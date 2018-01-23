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
    
    struct Spotify {
        static let markets: [String : String] = ["United States" : "us"]
        static let market = markets["United States"] ?? ""
        
        static let songpoint = { id in
            "https://api.spotify.com/v1/tracks/" + id + "&limit=" + searchlimit.description + "&market=" + market
        }
        
        struct artists {
            static let point = { id in
                "https://api.spotify.com/v1/artists/" + id + "&limit=" + searchlimit.description + "&market=" + market
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
        
        struct albums {
            static let point = { id in
                "https://api.spotify.com/v1/albums/" + id + "&limit=" + searchlimit.description + "&market=" + market
            }
            static let songspoint = { id in
                point(id) + "/tracks&limit=50&market=" + market
            }
        }
        
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
        static let votepoint = {(id: String, _ direction: Vote) -> String in
            switch direction {
            case .up: return "http://clique2016.herokuapp.com/playlists/" + id + "/upvote"
            case .down: return "http://clique2016.herokuapp.com/playlists/" + id + "/downvote"
            }
        }
        static let addpoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id + "/addSong"
        }
        static let newpoint = "http://clique2016.herokuapp.com/playlists/"
        static let advancepoint = {id in
            "http://clique2016.herokuapp.com/playlists/" + id + "/markSongAsPlayed"
        }
        static let deletepoint = { id in
            "http://clique2016.herokuapp.com/playlists/" + id
        }
        
        struct update {
            static let userpoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id
            }
            static let queuepoint = { id in
                 "http://clique2016.herokuapp.com/playlists/" + id + "/updateClique"
            }
            static let librarypoint = { id in
                "http://clique2016.herokuapp.com/playlists/" + id + "/loadSongs"
            }
        }
        
        //get clique with id
        //Alamofire.request(.GET, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/").responseJSON()
        
        //replace songlist with new list
        //Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/updateClique", parameters: ["songList": newlist], encoding: .JSON)
        
        //mark upcoming song as played -- need to change to not take parameters?
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/markSongAsPlayed", parameters: p1, encoding: .JSON)
        
        //update current song
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/changeSong", parameters: p2, encoding: .JSON)
        
        //upvote -- need to change to id based
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/upvote", parameters: p, encoding: .JSON)
        
        //downvote -- need to change to id based
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/downvote", parameters: p, encoding: .JSON)
        
        //load songs into library
        //Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/loadSongs", parameters: newlib, encoding: .JSON).responseJSON { response in
        //dispatch_async(dispatch_get_main_queue(), {
        //self.table.reloadData()
        //})
        //}
        
        //create new user
        //Alamofire.request(.POST, "http://clique2016.herokuapp.com/playlists/", parameters: newclique, encoding: .JSON)
        //}
        //load all playlists
        //"http://clique2016.herokuapp.com/playlists"
    }
}
