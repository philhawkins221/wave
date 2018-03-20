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
    
    private let user: User
    let controller: BrowseViewController
    var delegate: BrowseDelegate?
        
    //MARK: - initializers
    
    init?(to controller: BrowseViewController) {
        guard let found = CliqueAPI.find(user: controller.user) else { return nil }
        
        self.user = found
        self.controller = controller
        
        switch controller.mode {
        case .browse: delegate = BrowseDelegate(to: self)
        case .friends: delegate = FriendsDelegate(to: self)
        case .library: delegate = LibraryDelegate(to: self)
        case .playlist: delegate = PlaylistDelegate(to: self)
        case .sync: delegate = SyncDelegate(to: self)
        case .search: delegate = SearchDelegate(to: self)
        case .catalog: delegate = CatalogDelegate(to: self)
        }
        
        controller.profilebar?.manage(profile: user)
    }
    
    //MARK: - mutators
    
    func manage(user: User) {
        controller.user = user.id
        controller.profilebar?.manage(profile: user)
        
        update()
    }
    
    func update(with replacement: [Playlist]? = nil) {
        if let replacement = replacement {
            CliqueAPI.update(library: user, with: replacement)
        }
        
        controller.refresh()
    }
    
    //MARK: - accessors
    
    func client() -> User {
        var client = user
        
        if !client.me() { client.library = client.library.filter { $0.social } }
        
        return client
    }
    
    //MARK: - actions
    
    func add(songs: [Song]) {
        var playlist = controller.playlist
        playlist.songs.append(contentsOf: songs)
        if controller.mode == .playlist { controller.playlist = playlist }
        
        var replacement = user.library
        if let i = replacement.index(of: playlist) { replacement[i] = playlist }
        
        update(with: replacement)
        
        //TODO: sync with apple music or spotify if needed
    }
    
    func add(playlist: Playlist) {
        var replacement = user.library
        replacement.append(playlist)
        
        update(with: replacement)
    }
    
    //TODO: mutating func add(friend: String)
    
    func play(playlist: Playlist, at index: Int) {
        q.manager?.play(playlist: playlist, at: index)
    }
    
    func search(for end: BrowseMode, on vc: BrowseViewController) {
        controller.end = end
        vc.final = true
        vc.adding = false
        
        switch end {
        case .playlist: vc.navigationItem.prompt = "adding songs to " + controller.playlist.name
        case .friends: vc.navigationItem.prompt = "select a user to send a friend request"
        case .browse, .library, .sync, .search, .catalog: break
        }
        
        vc.user = user.id
        vc.mode = .friends
    }
    
    func find(friend: String? = nil, songs: [Song]? = nil) {
        if controller.final {
            
            for vc in controller.navigationController?.viewControllers as? [BrowseViewController] ?? [] {
                if vc.final { continue }
                
                if (vc.end == .friends && friend != nil && songs == nil) ||
                    (vc.end == .playlist && songs != nil && friend == nil) {
                    
                    vc.manager?.find(friend: friend, songs: songs)
                    Media.find()
                    controller.navigationController?.popToViewController(vc, animated: true)
                    
                    return
                }
            }
            
            return
        }
        
        controller.search.isActive = false
        
        if let friend = friend {} //TODO: add(friend: friend)
        if let songs = songs { add(songs: songs) }
    }
    
    func sync(playlist: Playlist? = nil) {
        if let playlist = playlist {
            add(playlist: playlist)
            controller.navigationController?.popViewController(animated: true)
            
            return
        }
        
        guard controller.mode == .playlist else { return }
        
        switch controller.playlist.library {
        case Catalogues.AppleMusic.rawValue:
            guard let playlist = Media.get(playlist: controller.playlist.id) else { return }
            controller.playlist = playlist
            var replacement = user.library
            if let i = replacement.index(of: playlist) { replacement[i] = playlist }
            update(with: replacement)
        case Catalogues.Spotify.rawValue: break //TODO: spotify sync
        default: break
        }
    }
    
    func view(user: String) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user
        vc.mode = .library
        controller.show(vc, sender: controller)
    }
    
    func view(playlist: Playlist) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.playlist = playlist
        vc.mode = .playlist
        controller.show(vc, sender: controller)
    }
    
    func view(songs: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.mode = .browse
        controller.show(vc, sender: controller)
    }
    
    func view(sync: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.mode = .sync
        controller.show(vc, sender: controller)
    }
    
    func view(search query: String, from sender: String) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
            else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.query = query
        vc.mode = .search
        
        switch sender {
        case _ where sender.contains("search username"): vc.searching = .users
        case _ where sender.contains("search Device Library"):
            vc.searching = .library
            Media.search(multiple: !controller.adding, on: controller)
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
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.catalog = item
        vc.mode = .catalog
        controller.show(vc, sender: controller)
    }
    
}
