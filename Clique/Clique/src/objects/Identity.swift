//
//  Identity.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Identity {
    
    //MARK: - properties
    
    static var me: String = UserDefaults.standard.string(forKey: "id") ?? ""
    static var friends = [String]()
    static var applemusic = false
    static var spotify = false
    
    //MARK: - actions
    
    static func wave() {
        if UserDefaults.standard.string(forKey: "id") != nil { return }
        let new = User(
            "anonymous",
            id: "",
            friends: [],
            requests: [],
            queue: Queue(),
            library: [],
            applemusic: false,
            spotify: false
        )
        
        guard let me = CliqueAPI.new(user: new) else { return }
        //TODO: what to do if this is nil
        //perhaps wave should return bool
        self.me = me.id
        UserDefaults.standard.set(me.id, forKey: "id")
    }
    
    static func connect(applemusic status: Bool) { //TODO: update clique api
        applemusic = status
        
        if var replacement = CliqueAPI.find(user: me) {
            replacement.applemusic = applemusic
            update(with: replacement)
        }
    }
    
    static func connect(spotify status: Bool) { //TODO: update clique api
        spotify = status
        
        if var replacement = CliqueAPI.find(user: me) {
            replacement.spotify = spotify
            update(with: replacement)
        }
    }
    
    static func update(with replacement: User? = nil) {
        if let replacement = replacement, replacement.me() {
            CliqueAPI.update(user: replacement)
        }
    }
    
}
