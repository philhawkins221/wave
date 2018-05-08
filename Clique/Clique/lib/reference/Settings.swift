//
//  Settings.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Settings {
    
    //MARK: - general
    
    static var applemusic = false {
        didSet { if applemusic != oldValue { gm?.connect(applemusic: applemusic) } }
    }
    static var spotify = false {
        didSet { if spotify != oldValue { gm?.connect(spotify: spotify) } }
    }
    
    //MARK: - browse
    
    static var sharing = [Playlist]()
    
    //MARK: - queue
    
    static var donotdisturb = false {
        didSet {
            guard donotdisturb != oldValue,
                var replacement = CliqueAPI.find(user: Identity.me)?.queue
            else { return }
            
            replacement.donotdisturb = donotdisturb
            CliqueAPI.update(queue: replacement)
        }
    }
    static var requestsonly = false {
        didSet {
            guard requestsonly != oldValue,
                var replacement = CliqueAPI.find(user: Identity.me)?.queue
            else { return }
            
            replacement.requestsonly = requestsonly
            CliqueAPI.update(queue: replacement)
        }
    }
    static var takerequests = false
    
    static var voting = false {
        didSet { if voting != oldValue { gm?.voting(status: voting) } }
    }
    static var radio = false {
        didSet {
            guard radio != oldValue,
                var replacement = CliqueAPI.find(user: Identity.me)?.queue
            else { return }
            
            replacement.radio = radio
            CliqueAPI.update(queue: replacement)
        }
    }
    static var shuffle = UserDefaults.standard.bool(forKey: "shuffle") {
        didSet {
            UserDefaults.standard.set(shuffle, forKey: "shuffle")
            if q.manager != nil { q.manager?.refresh() }
        }
    }
    
    //MARK: - update
    
    static func update() {
        guard let me = CliqueAPI.find(user: Identity.me) else { return }
        
        applemusic = me.applemusic
        spotify = me.spotify
        
        sharing = me.library
        
        donotdisturb = me.queue.donotdisturb
        requestsonly = me.queue.requestsonly
        
        voting = me.queue.voting
        radio = me.queue.radio
    }
    
    static func update(_ setting: Setting) {
        switch setting {
        case .applemusic: applemusic = !applemusic
        case .spotify: spotify = !spotify
        case .donotdisturb: donotdisturb = !donotdisturb
        case .requestsonly: requestsonly = !requestsonly
            if requestsonly { takerequests = true }
        case .takerequests: takerequests = !takerequests
        case .voting: voting = !voting
        case .radio: radio = !radio
        case .shuffle: shuffle = !shuffle
        case .stopSharing: gm?.stop(sharing: ())
        case .stopListening: gm?.stop(listening: ())
        case .sharing, .delete, .none: break
        }
    }
    
}
