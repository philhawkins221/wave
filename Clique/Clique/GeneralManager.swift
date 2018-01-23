//
//  GeneralManager.swift
//  Clique
//
//  Created by Phil Hawkins on 1/20/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct GeneralManager {
    
    //MARK: - properties
    
    static private var instance: GeneralManager?
    
    var controller: NowPlayingViewController?
    var nowplaying: Song? {
        willSet { controller?.nowplaying(song: newValue) }
    }
    
    //MARK: - initializers
    
    static func sharedInstance() -> GeneralManager {
        
        if instance == nil {
            instance = GeneralManager()
        }
        
        return instance!
    }
    
    private init() {
        
    }
    
    //MARK: - mutators
    
    static func manage(user: User) throws {
        if instance == nil { throw ManagementError.unsetInstance }
        
        instance?.controller?.profilebar.manage(profile: user)
    }
    
    static func manage(controller: NowPlayingViewController) throws {
        switch instance {
        case nil: throw ManagementError.unsetInstance
        default: instance?.controller = controller
        }
    }
    
    //MARK: - accessors
    
    func client() -> User? {
        return Identity.sharedInstance().me
    }
    
    //MARK: - actions
    
    func update(to result: User? = nil) {
        try? GeneralManager.manage(user: Identity.sharedInstance().me)
    }
}
