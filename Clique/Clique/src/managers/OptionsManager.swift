//
//  OptionsManager.swift
//  Clique
//
//  Created by Phil Hawkins on 3/24/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct OptionsManager {
    
    //MARK: - properties
    
    let controller: UIViewController
    var delegate: OptionsDelegate?
    
    //MARK: - initializers
    
    init(to controller: UIViewController) {
        self.controller = controller
        delegate = OptionsDelegate(to: self)
        
        //TODO: present()
    }
    
    //MARK: - tasks
    
    func execute(_ option: Option) {
        switch option {
        case .settings: break
        case .friendRequests: break
        case .checkFrequencies: break
        case .shareQueue: break
        case .shuffle: break
        case .addFriend: break
        case .removeFriend: break
        case .addPlaylist: break
        case .removePlaylist: break
        case .joinQueue: break
        case .playPlaylist: break
        case .addPlaylistToLibrary: break
        case .sharePlaylist: break
        case .playAll: break
        case .playCatalog: break
        case .addHistoryPlaylist: break
        case .stopSharing: break
        case .stopListening: break
        case .stopViewing: break
        case .stopSyncing: break
        case .addCatalogToLibrary: break
        case .none: break
        }
    }
    
}
