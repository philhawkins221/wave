//
//  GracenoteAPI.swift
//  Clique
//
//  Created by Phil Hawkins on 5/15/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct GracenoteAPI {
    
    static func register() {
        let endpoint = Endpoints.Gracenote.registerpoint
        
        if let response = Web.call(.get, to: endpoint) {
            gracenoteUserID = response["RESPONSE"][0]["USER"][0]["VALUE"].string ?? ""
        }
    }
    
    static func recommend(from seeds: [Song]) -> [Single] {
        if gracenoteUserID == "" { register() }
        let endpoint = Endpoints.Gracenote.recommendpoint(seeds)
        var results = [Single]()
        
        if let response = Web.call(.get, to: endpoint) {
            let recommendations = response["RESPONSE"][0]["ALBUM"].array ?? []
            
            for song in recommendations {
                results.append(Single(
                    title: song["TRACK"][0]["TITLE"][0]["VALUE"].string ?? "",
                    artist: song["ARTIST"][0]["VALUE"].string ?? ""
                ))
            }
        }
        
        return results
    }
}
