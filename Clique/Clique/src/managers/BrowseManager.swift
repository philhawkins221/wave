//
//  BrowseManager.swift
//  Clique
//
//  Created by Phil Hawkins on 1/17/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct BrowseManager {
    
    //MARK: - properties
    
    private var user: User
    var controller: BrowseViewController
    var delegate: BrowseDelegate?
    var adding: Bool
    
    //MARK: - initializers
    
    init?(to controller: BrowseViewController, for user: String = Identity.sharedInstance().me) {
        guard let found = CliqueAPI.find(user: user) else { return nil }
        
        self.user = found
        self.controller = controller
        adding = false
        
        update()
    }
    
    init?(to controller: BrowseViewController, with delegate: BrowseDelegate, for user: String = Identity.sharedInstance().me) {
        self.init(to: controller, for: user)
        self.delegate = delegate
        
        update()
    }
    
    //MARK: - mutators
    
    mutating func manage(user: User) {
        self.user = user
        controller.profilebar.manage(profile: user)
    }
    
    mutating func update(with replacement: [Playlist]? = nil) {
        if let replacement = replacement {
            CliqueAPI.update(library: user, with: replacement)
        }
        
        refresh()
    }
    
    private mutating func refresh() {
        guard let found = CliqueAPI.find(user: user.id) else { return }
        
        manage(user: found)
        delegate?.populate()
        controller.table.reloadData()
    }
    
    //MARK: - accessors
    
    func client() -> User {
        var client = user.clone()
        
        if !client.me() { client.library = client.library.filter { $0.social } }
        
        return client
    }
    
    //MARK: - actions
    
    func view(user: String) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        if let manager = BrowseManager(to: vc, for: user) {
            vc.manager = manager
            vc.manager?.delegate = LibraryDelegate(to: vc.manager!)
        }
        
        controller.show(vc, sender: controller)
    }
    
    func view(playlist: Playlist) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        if let manager = BrowseManager(to: vc, for: user.id) {
            vc.manager = manager
            vc.manager?.delegate = PlaylistDelegate(to: vc.manager!, for: playlist)
        }
        
        controller.show(vc, sender: controller)
    }
    
    func viewAllSongs() {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        if let manager = BrowseManager(to: vc, for: user.id) {
            vc.manager = manager
            vc.manager?.delegate = BrowseDelegate(to: vc.manager!)
        }
        
        controller.show(vc, sender: controller)
    }
    
    func viewSyncPlaylists() {
        
    }
    
    mutating func add(playlist: Playlist) {
        var replacement = user.library
        replacement.append(playlist)
        
        update(with: replacement)
    }
    
    func play(playlist: Playlist, at index: Int) {
        q.manager?.play(playlist: playlist, at: index)
    }
    
    func search(query: String, in library: Catalogues) {
        
    }
    
    func queue(song: Song) {
        if !adding { return }
        
        //TODO: QueueManager.sharedInstance().add()
    }
}
