//
//  LibraryManager.swift
//  Clique
//
//  Created by Phil Hawkins on 1/12/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct LibraryManager {
    
    //MARK: - properties
    
    static private var instance: LibraryManager?
    
    private var user: User?
    var controller: LibraryViewController?
    var delegate: LibraryDelegate
    var display: Playlist?
    var adding: Bool
    
    //MARK: - initializers
    
    static func sharedInstance() -> LibraryManager {
        
        if instance == nil {
            instance = LibraryManager()
        }
        
        return instance!
    }
    
    private init() {
        delegate = LibraryDelegate()
        adding = false
    }
    
    //MARK: - mutators
    
    static func manage(user: User) throws {
        switch instance {
        case nil: throw ManagementError.unsetInstance
        default:
            instance?.user = user
            instance?.controller?.profilebar.manage(profile: user)
        }
    }
    
    static func manage(display: Playlist?) throws {
        switch instance {
        case nil: throw ManagementError.unsetInstance
        default: instance?.display = display
        }
    }
    
    static func manage(controller: LibraryViewController) throws {
        switch instance {
        case nil: throw ManagementError.unsetInstance
        default: instance?.controller = controller
        }
    }
    
    static func removeDisplay() {
        instance?.display = nil
    }
    
    //MARK: - accessors
    
    func client() -> User? {
        refresh()
        
        let clone = user?.clone()
        
        return clone
    }
    
    //MARK: - actions
    
    private func refresh() {
        if let found = CliqueAPIUtility.find(user: user?.id ?? "") {
            try? LibraryManager.manage(user: found)
        }
    }
    
    func view(playlist: Playlist) {
        //refresh user
        try? LibraryManager.manage(display: playlist)
        
        guard let vc = controller?.storyboard?.instantiateViewController(withIdentifier: VCid.lib.rawValue) else { return }
        controller?.show(vc, sender: self)
    }
    
    func viewAllPlaylists() {
        try? LibraryManager.manage(display: nil)
    }
    
    func viewAllSongs() {
        
    }
    
    func play(playlist: Playlist, at index: Int) {
        //refresh user
        //alert -> start playing, put playlist in queue
    }
    
    func queue(song: Song) {
        //use QueueManager.sharedInstance().client()
    }
    
    func update(for replacements: [Playlist] = [], with additions: [Playlist] = [], to result: [Playlist]? = nil) {
        guard let user = client() else { return }
        
        //result
        if let result = result {
            CliqueAPIUtility.update(library: user, with: result)
            return
        }
        
        var result = [Playlist]()
        
        //replacements
        result = user.library.map {
            for replacement in replacements {
                if $0 == replacement {
                    return replacement
                }
            }
            return $0
        }
        
        //additions
        result.append(contentsOf: additions)
        
        if !replacements.isEmpty || !additions.isEmpty {
            CliqueAPIUtility.update(library: user, with: result)
        }
        refresh()
    }
}
