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
    static var applemusic = false
    static var spotify = false
    
    //MARK: - actions
    
    static func wave() {
        if me != "", let _ = CliqueAPI.find(user: me) { return }
        
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
        print("Identity wave:", me)
        self.me = me.id
        UserDefaults.standard.set(me.id, forKey: "id")
        
        let likes = Playlist(
            owner: me.id,
            id: "0",
            library: Catalogues.Library.rawValue,
            name: "likes",
            social: true,
            songs: []
        )
        
        CliqueAPI.update(playlist: me.id, with: likes)
    }
    
    static func update(with replacement: User? = nil) {
        if let replacement = replacement, replacement.me() {
            CliqueAPI.update(user: replacement)
        }
    }
    
}
