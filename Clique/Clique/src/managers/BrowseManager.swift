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
    
    init?(to controller: BrowseViewController) {
        guard let found = CliqueAPI.find(user: controller.user) else { return nil }
        
        self.user = found
        self.controller = controller
        adding = false
        
        switch controller.mode {
        case .browse: delegate = BrowseDelegate(to: self)
        case .friends: delegate = FriendsDelegate(to: self)
        case .library: delegate = LibraryDelegate(to: self)
        case .playlist: delegate = PlaylistDelegate(to: self)
        case .sync: delegate = SyncDelegate(to: self)
        case .search: delegate = SearchDelegate(to: self)
        case .catalog: delegate = CatalogDelegate(to: self)
        }
        
        update()
    }
    
    //MARK: - mutators
    
    mutating func manage(user: User) {
        self.user = user
        controller.profilebar.manage(profile: user)
        delegate?.manager = self
    }
    
    mutating func update(with replacement: [Playlist]? = nil) {
        if let replacement = replacement {
            CliqueAPI.update(library: user, with: replacement)
        }
        
        refresh()
    }
    
    private mutating func refresh() {
        guard let found = CliqueAPI.find(user: user.id) else { return }
        if delegate == nil { delegate = FriendsDelegate(to: self) }
        
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
        
        vc.user = user
        vc.mode = .library
        controller.show(vc, sender: controller)
    }
    
    func view(playlist: Playlist) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.user = user.id
        vc.playlist = playlist
        vc.mode = .playlist
        controller.show(vc, sender: controller)
    }
    
    func view(songs: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.user = user.id
        vc.mode = .browse
        controller.show(vc, sender: controller)
    }
    
    func view(sync: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.user = user.id
        vc.mode = .sync
        controller.show(vc, sender: controller)
    }
    
    func view(search query: String, from sender: String) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
            else { return }
        
        vc.user = user.id
        vc.query = query
        vc.mode = .search
        
        switch sender {
        case _ where sender.contains("search username"): vc.searching = .users
        case _ where sender.contains("search Device Library"):
            vc.searching = .library
            let picker = Media.picker(with: delegate!)
            controller.present(picker, animated: true)
            return
        case _ where sender.contains("search Apple Music"): vc.searching = .applemusic
        case _ where sender.contains("search Spotify"): vc.searching = .spotify
        default: vc.searching = .none
        }
        
        controller.show(vc, sender: controller)
    }
    
    func view(catalog item: CatalogItem) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
            else { return }
        
        vc.user = user.id
        vc.catalog = item
        vc.mode = .catalog
        controller.show(vc, sender: controller)
    }
    
    mutating func add(playlist: Playlist) {
        var replacement = user.library
        replacement.append(playlist)
        
        update(with: replacement)
    }
    
    func play(playlist: Playlist, at index: Int) {
        q.manager?.play(playlist: playlist, at: index)
    }
    
    func search(query: String) {
        
    }
    
    func queue(song: Song) {
        if !adding { return }
        
        //TODO: QueueManager.sharedInstance().add()
    }
}
