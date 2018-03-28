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
        
        controller.profilebar.manage(profile: found)
    }
    
    //MARK: - tasks
    
    func add(songs: [Song]) {
        var playlist = controller.playlist
        playlist.songs.append(contentsOf: songs)
        if controller.mode == .playlist { controller.playlist = playlist }
        
        update(playlist: playlist)
        
        //TODO: sync with apple music or spotify if needed
    }
    
    func add(playlist: Playlist) {
        update(playlist: playlist)
    }
    
    func add(friend: User) {
        gm?.add(friend: friend)
        refresh()
    }
    
    func client() -> User {
        var client = user
        if !client.me() { client.library = client.library.filter { $0.social } }
        
        return client
    }
    
    func delete(friend: User, confirmed: Bool) {
        guard confirmed else { return Alerts.delete(friend: friend, on: controller) }
        
        gm?.delete(friend: friend.id)
        refresh()
    }
    
    func delete(playlist: Playlist) {
        CliqueAPI.delete(playlist: playlist, for: user.id)
        refresh()
    }

    func find(friend: User, confirmed: Bool) {
        guard confirmed else { return Alerts.add(friend: friend, on: controller) }
        
        if controller.final {
            
            for vc in controller.navigationController?.viewControllers as? [BrowseViewController] ?? [] {
                if vc.final { continue }
                
                if vc.end == .friends {
                    
                    vc.manager?.find(friend: friend, confirmed: confirmed)
                    print("put it in my but ooo put it in good")
                    Media.find()
                    controller.navigationController?.popToViewController(vc, animated: true)
                    
                    return
                }
            }
            
            return
        }
        
        controller.search.isActive = false
        add(friend: friend)
    }
    
    func find(songs: [Song]) {
        if controller.final {
            
            for vc in controller.navigationController?.viewControllers as? [BrowseViewController] ?? [] {
                if vc.final { continue }
                
                if vc.end == .playlist {
                    
                    vc.manager?.find(songs: songs)
                    Media.find()
                    controller.navigationController?.popToViewController(vc, animated: true)
                    
                    return
                }
            }
            
            return
        }
        
        controller.search.isActive = false
        add(songs: songs)
    }
    
    func manage(user: User) {
        controller.user = user.id
        refresh()
    }
    
    func play(playlist: Playlist, at index: Int) {
        q.manager?.play(playlist: playlist, at: index)
    }
    
    func refresh() {
        controller.refresh()
    }
    
    func search(for end: BrowseMode, on vc: BrowseViewController) {
        controller.end = end
        vc.final = true
        vc.adding = false
        
        switch end {
        case .playlist: vc.navigationItem.prompt = "adding songs to " + controller.playlist.name
        case .friends: vc.navigationItem.prompt = "sending friend request"
        case .browse, .library, .sync, .search, .catalog: break
        }
        
        vc.user = user.id
        vc.mode = .friends
    }
    
    func share(playlist enabled: Bool = true) {
        guard controller.mode == .playlist else { return }
        controller.playlist.social = enabled
        update(playlist: controller.playlist)
    }

    func sync(new playlist: Playlist) {
        add(playlist: playlist)
        controller.navigationController?.popViewController(animated: true)
    }
    
    func sync(confirmed: Bool) {
        guard controller.mode == .playlist else { return }
        guard confirmed else { return Alerts.sync(playlist: (), on: controller) }
        
        switch controller.playlist.library {
        case Catalogues.AppleMusic.rawValue:
            guard let playlist = Media.get(playlist: controller.playlist.id) else { return }
            controller.playlist = playlist
            update(playlist: playlist)
        case Catalogues.Spotify.rawValue: break //TODO: spotify sync
        default: break
        }
    }
    
    func update(library replacement: [Playlist]) {
        CliqueAPI.update(library: user.id, with: replacement)
        refresh()
    }
    
    func update(playlist replacement: Playlist) {
        CliqueAPI.update(playlist: user.id, with: replacement)
        refresh()
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
