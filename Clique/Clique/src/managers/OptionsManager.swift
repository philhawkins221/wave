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
    
    let controller: OptionsTableViewController
    let profilebar: ProfileBar?
    var delegate: OptionsDelegate?
    
    var selections: [Int] {
        get {
        var selections = [Int]()
        Options.options.options.indices.forEach { i in
            switch Options.options.options[i] {
            case .shuffle: if q.shuffle { selections.append(i) }
            case .sharePlaylist:
                guard let controller = profilebar?.controller as? BrowseViewController else { break }
                if controller.playlist.social { selections.append(i) }
            default: break
            }
        }
        return selections
        } set {
            //controller.refresh()
            
        }
    }
        
    //MARK: - initializers
    
    init(to controller: OptionsTableViewController, with profile: ProfileBar?) {
        self.controller = controller
        profilebar = profile
        delegate = OptionsDelegate(to: self)
    }
    
    //MARK: - tasks
    
    func disappear() {
        profilebar?.openclose(controller)
    }
        
    func execute(_ option: Option) { //TODO: execute
        switch option {
        case .settings: break
        case .friendRequests: break
        case .checkFrequencies: break
        case .shareQueue: break
        
        case .shuffle: q.manager?.shuffle(enabled: !q.shuffle)
        
        case .addFriend:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .friends else { return }
            controller.performSegue(withIdentifier: "add", sender: controller)
        
        case .removeFriend:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                  controller.mode == .friends else { return }
            controller.table.setEditing(true, animated: true)
        
        case .addPlaylist:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .library else { return }
            Alerts.add(playlist: (), on: controller)
            //controller.performSegue(withIdentifier: "add", sender: controller)
        
        case .removePlaylist:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .library else { return }
            controller.edit(controller)
        
        case .joinQueue:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .library,
                let user = CliqueAPI.find(user: controller.user) else { return }
            gm?.listen(to: user.id)
        
        case .addUser:
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .library else { return }
            CliqueAPI.add(friend: controller.user, to: Identity.me)
            disappear()
        
        case .playPlaylist:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .playlist else { return }
            controller.manager?.play(playlist: controller.playlist, at: 0)
        
        case .addPlaylistToLibrary:
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .playlist else { return }
            CliqueAPI.update(playlist: Identity.me, with: controller.playlist)
            disappear()
        
        case .sharePlaylist:
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .playlist else { return }
            controller.manager?.share(playlist: !controller.playlist.social)
            
        case .playAll:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .browse,
                let all = controller.manager?.delegate?.all else { return }
            controller.manager?.play(playlist: all, at: 0)
            
        case .playCatalog:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .catalog else { return }
            controller.manager?.delegate?.tableView(controller.table, didSelectRowAt: IndexPath(row: 0, section: 0))
            
        case .addHistoryPlaylist: break
            
        case .stopSharing:
            disappear()
            gm?.stop(sharing: ())
            
        case .stopListening:
            disappear()
            gm?.stop(listening: ())
            
        case .stopViewing, .stopSyncing:
            switch profilebar?.controller {
            case is BrowseViewController: bro.navigationController?.popToRootViewController(animated: true)
            case is QueueViewController: q.navigationController?.popToRootViewController(animated: true)
            default: break
            }
            
        case .addCatalogToLibrary: break
        case .none: break
        }
    }
    
}
