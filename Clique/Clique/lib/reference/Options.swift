//
//  Options.swift
//  Clique
//
//  Created by Phil Hawkins on 3/24/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Options {
    
    static var options = OptionSet(options: [], stop: nil)
    static var height = 0
    
    static func assess(for controller: UIViewController) {
        var options = OptionSet(options: [], stop: nil)
        
        switch controller {
        case is NowPlayingViewController:
            let sharing = (q.manager?.client().me() ?? false) && q.manager?.client().queue.current != nil
            let listening = !(q.manager?.client().me() ?? true)
            options.options = [.settings, .friendRequests, .checkFrequencies]
            options.stop = sharing ? .stopSharing : listening ? .stopListening : nil
        
        case let controller as BrowseViewController:
            let me = controller.manager?.client().me() ?? false
            switch controller.mode {
            case .browse:
                options.options = [.settings, .playAll]
                options.stop = me ? nil : .stopViewing
            case .friends:
                options.options = [.settings, .addFriend, .removeFriend]
                options.stop = me ? nil : .stopViewing
            case .library where me:
                options.options = [.settings, .addPlaylist, .removePlaylist]
            case .library:
                guard let me = CliqueAPI.find(user: Identity.me),
                      let client = controller.manager?.client() else { return }
                options.options = me.friends.contains(client.id) ? [.settings, .joinQueue] : [.settings, .addUser]
                options.stop = .stopViewing
            case .playlist where me:
                options.options = [.settings, .playPlaylist, .sharePlaylist]
            case .playlist:
                options.options = [.settings, .playPlaylist, .addPlaylistToLibrary]
                options.stop = .stopViewing
            case .sync:
                options.options = [.settings]
                options.stop = .stopSyncing
            case .search:
                options.options = [.settings]
                options.stop = .stopViewing
            case .catalog:
                options.options = [.settings, .playCatalog, .addCatalogToLibrary]
                options.stop = me ? nil : .stopViewing
            }
            
        case let controller as QueueViewController:
            let me = controller.manager?.client().me() ?? false
            switch controller.mode {
            case .queue where me:
                let client = q.manager?.client()
                let sharing = (client?.me() ?? false) && (client?.queue.current != nil || !(client?.queue.listeners.isEmpty ?? true))
                options.options = [.settings, .shareQueue, .shuffle]
                options.stop = sharing ? .stopSharing : nil
            case .queue:
                options.options = [.settings, .addSong] //, .addQueuePlaylistToLibrary]
                options.stop = .stopListening
            case .history:
                options.options = [.settings, .addHistoryPlaylist]
                options.stop = me ? nil : .stopListening
            case .listeners: break //TODO: new options
            case .requests: break
            case .radio: break
            }
            
        case _ where options.stop == nil: break //TODO: smart stop
            
        default: break
        }
        
        self.options = options
        height = options.options.count * 60
        if options.stop != nil { height += 80 }
    }
    
}
