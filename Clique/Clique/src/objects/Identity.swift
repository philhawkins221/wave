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
    
    static var me: String! = UserDefaults.standard.string(forKey: "id")
    static var friends: [String] = UserDefaults.standard.stringArray(forKey: "friends") ?? []
    static var applemusic: Bool = UserDefaults.standard.bool(forKey: "applemusic")
    static var spotify: Bool = UserDefaults.standard.bool(forKey: "spotify")
    
    //MARK: - actions
    
    static func wave() {
        if UserDefaults.standard.string(forKey: "id") != nil { return }
        let new = User("anonymous",
                       id: "",
                       queue: Queue(),
                       library: [],
                       applemusic: false,
                       spotify: false)
        
        me = CliqueAPI.new(user: new)!.id
        //TODO: what to do if this is nil
        
        UserDefaults.standard.set(me, forKey: "id")
        UserDefaults.standard.set(friends, forKey: "friends")
    }
    
    static func connect(applemusic status: Bool) {
        applemusic = status
        UserDefaults.standard.set(status, forKey: "applemusic")
        
        if var replacement = CliqueAPI.find(user: me) {
            replacement.applemusic = applemusic
            update(with: replacement)
        }
    }
    
    static func connect(spotify status: Bool) {
        spotify = status
        UserDefaults.standard.set(status, forKey: "spotify")
        
        if var replacement = CliqueAPI.find(user: me) {
            replacement.spotify = spotify
            update(with: replacement)
        }
    }
    
    static func update(with replacement: User? = nil) {
        if let replacement = replacement, replacement.id == me {
            CliqueAPI.update(user: replacement)
        }
    }
    
}
