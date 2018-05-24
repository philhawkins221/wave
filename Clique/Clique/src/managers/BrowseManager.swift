//
//  BrowseManager.swift
//  Clique
//
//  Created by Phil Hawkins on 1/17/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

///manages a user's information for a `BrowseViewController`
struct BrowseManager {
    
    //MARK: - properties
    
    ///the user whose information is being managed (cached)
    private let user: User
    ///the view controller on which the user's information is being displayed
    let controller: BrowseViewController
    ///the delegate for this manager
    var delegate: BrowseDelegate?
        
    //MARK: - initializers

    
    /**
    initializes a `BrowseManager` for a given `BrowseViewController` and pulls a user from server with the user id provided by the controller. fails if a valid user cannot be found with the user id provided.
 
     - parameters:
        - controller: the controller displaying the user's information
    */
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
    
    /**
     adds a list of songs to the end of the playlist being displayed by the controller.
     
     - parameters:
        - songs: the songs to add to the playlist
    */
    func add(songs: [Song]) {
        var playlist = controller.playlist
        playlist.songs.append(contentsOf: songs)
        if controller.mode == .playlist { controller.playlist = playlist }
        update(playlist: playlist)
    }
    
    /**
     adds a given playlist to the user's library.
     
     - parameters:
        - playlist: the playlist to add to the library
    */
    func add(playlist: Playlist) {
        update(playlist: playlist)
    }
    
    /**
     tells the general manager to add a given user as a friend.
     
     - parameters:
        - friend: the user to add as a friend
    */
    func add(friend: User) {
        gm?.add(friend: friend.id)
        refresh()
    }
    
    /// - returns: the user being managed
    func client() -> User {
        var client = user
        if !client.me() { client.library = client.library.filter { $0.social } }
        
        return client
    }
    
    /**
     tells the general manager to delete a given user from friends.
     
     - parameters:
        - friend: the user to delete from friends
        - confirmed: if the task has been confirmed by the end user, default value is `false`
    */
    func delete(friend: User, confirmed: Bool = false) {
        guard confirmed else { return Alerts.delete(friend: friend, on: controller) }
        
        gm?.delete(friend: friend.id)
        refresh()
    }
    
    /**
     deletes a given playlist from the user's library.
     
     - parameters:
        - playlist: the playlist to delete from the library
    */
    func delete(playlist: Playlist) {
        CliqueAPI.delete(playlist: playlist, for: user.id)
        refresh()
    }

    /**
     ends the current search and adds a given user to friends.
     
     - parameters:
        - friend: the user to add to friends
        - confirmed: if the task has been confirmed by the end user, default value is `false`
    */
    func find(friend: User, confirmed: Bool = false) {
        guard confirmed else { return Alerts.add(friend: friend, on: controller) }
        
        if controller.final {
            
            for vc in controller.navigationController?.viewControllers as? [BrowseViewController] ?? [] {
                if vc.final { continue }
                
                if vc.end == .friends {
                    
                    vc.manager?.find(friend: friend, confirmed: confirmed)
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
    
    /**
     ends the current search and adds a given list of songs to the end of the playlist being displayed by the controller.
     
     - parameters:
        - songs: the list of songs to add to the playlist
    */
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
    
    /**
     manages a given user's information.
     
     - parameters:
        - user: the user to manage
    */
    func manage(user: User) {
        controller.user = user.id
        refresh()
    }
    
    /**
     tells the queue manager to play a song in a given playlist.
     
     - parameters:
        - playlist: the playlist containing the selected song
        - index: the index of the song to play in the list of songs in `playlist`
    */
    func play(playlist: Playlist, at index: Int) {
        q.manager?.play(playlist: playlist, at: index)
    }
    
    ///updates the user's information from server.
    ///- note: this manager will be deinitialized
    func refresh() {
        controller.refresh()
    }
    
    /**
     starts a search on top of the current controller.
     
     - parameters:
        - end: determines the expected result of the search
        - vc: the controller displaying the search
    */
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
    
    /**
     sets the sharing status for the playlist being displayed by the controller.
     
     - note: current controller must be displaying a playlist
     
     - parameters:
        - enabled: if sharing is enabled for the playlist, default value is `true`
    */
    func share(playlist enabled: Bool = true) {
        guard controller.mode == .playlist else { return }
        controller.playlist.social = enabled
        update(playlist: controller.playlist)
    }

    /**
     adds a given synced playlist to the user's library.
     
     - parameters:
        - playlist: the synced playlist to add
    */
    func sync(new playlist: Playlist) {
        add(playlist: playlist)
        controller.navigationController?.popViewController(animated: true)
    }
    
    /**
     re-syncs the synced playlist being displayed by the controller.
     
     - parameters:
        - confirmed: if the task has been confirmed by the end user
    */
    func sync(confirmed: Bool = false) {
        guard controller.mode == .playlist else { return }
        guard confirmed else { return Alerts.sync(playlist: (), on: controller) }
        
        switch controller.playlist.library {
        case Catalogues.AppleMusic.rawValue:
            guard let playlist = Media.get(playlist: controller.playlist.id) else { return }
            controller.playlist = playlist
            update(playlist: playlist)
        case Catalogues.Spotify.rawValue: break
        default: break
        }
    }
    
    /**
     updates the library to server for the user.
     
     - parameters:
        - replacement: the user's updated library
    */
    func update(library replacement: [Playlist]) {
        CliqueAPI.update(library: user.id, with: replacement)
        refresh()
    }
    
    /**
     updates the playlist to server for the user.
     
     - parameters:
        - replacement: the user's updated playlist
     */
    func update(playlist replacement: Playlist) {
        CliqueAPI.update(playlist: user.id, with: replacement)
        refresh()
    }

    /**
     shows a new controller displaying a given user's library.
     
     - parameters:
        - user: the user id of the user to view
    */
    func view(user: String) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user
        vc.mode = .library
        
        controller.dismiss(animated: true)
        controller.show(vc, sender: controller)
    }
    
    /**
     shows a new controller displaying a playlist.
     
     - parameters:
     - playlist: the playlist to view
     */
    func view(playlist: Playlist) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.playlist = playlist
        vc.mode = .playlist
        
        controller.dismiss(animated: true)
        controller.show(vc, sender: controller)
    }
    
    /**
     shows a new controller displaying all the song in the user's library.
     
     - parameters:
        - songs: _
    */
    func view(songs: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.mode = .browse
        
        controller.dismiss(animated: true)
        controller.show(vc, sender: controller)
    }
    
    /**
    shows a new controller displaying all the playlists available to sync.
 
     - parameters:
        - sync: _
    */
    func view(sync: Void) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
        else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.mode = .sync
        
        controller.dismiss(animated: true)
        controller.show(vc, sender: controller)
    }
    
    /**
     shows a new controller displaying the results of an end user search.
     
     - parameters:
        - query: the query entered by the end user
        - sender: the type of search requested
    */
    func view(search query: String, from sender: SearchMode) {
        guard sender != .library else { return Media.search(multiple: !controller.adding, on: controller) }
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
            else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = Identity.me
        vc.query = query
        vc.mode = .search
        vc.searching = sender
        
        controller.dismiss(animated: true)
        controller.show(vc, sender: controller)
    }
    
    /**
     shows a new controller displaying a given catalog item.
     
     - parameters:
        - item: the catalog item to view
    */
    func view(catalog item: CatalogItem) {
        guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
            else { return }
        
        vc.final = controller.final
        vc.adding = controller.adding
        vc.navigationItem.prompt = controller.navigationItem.prompt
        vc.user = user.id
        vc.catalog = item
        vc.mode = .catalog
        
        controller.dismiss(animated: true)
        controller.show(vc, sender: controller)
    }
    
}
