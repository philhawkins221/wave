//
//  LibraryManager.swift
//  Clique
//
//  Created by Phil Hawkins on 1/12/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct LibraryManager {
    static var instance: LibraryManager?
    
    private var user: User
    var controller: LibraryViewController
    var table: UITableView
    var delegate: LibraryDelegate
    var display: Playlist?
    var adding: Bool
    
    static func sharedInstance() -> LibraryManager {
        
        if instance == nil {
            instance = LibraryManager()
        }
        
        return instance!
    }
    
    private init() {
        
        
    }
    
    //MARK: mutators
    
    static func manage(user: User) {
        instance?.user = user
    }
    
    static func manage(display: Playlist) {
        instance?.display = display
    }
    
    static func manage(table: UITableView) {
        instance?.table = table
    }
    
    static func manage(controller: LibraryViewController) {
        instance?.controller = controller
    }
    
    static func removeDisplay() {
        instance?.display = nil
    }
    
    //MARK: accessors
    
    func client() -> User {
        let clone = user.clone()
        
        return clone
    }
    
    //MARK: actions
    
    func refresh() {
        
    }
    
    func view(playlist: Playlist) {
        //refresh user
        LibraryManager.manage(display: playlist)
        
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.lib.rawValue) else { return }
        controller.show(vc, sender: self)
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
    
    func update(with replacements: [Playlist] = [], to result: [Playlist]? = nil) {
        //if result is not nil, perform library update with that
        //if replacements is not empty, for each replace playlist in library that is ==
        //otherwise, refresh()

    }
}
