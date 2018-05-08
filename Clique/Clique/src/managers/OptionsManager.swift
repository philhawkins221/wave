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
            case .shuffle: if Settings.shuffle { selections.append(i) }
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
        
    func execute(_ option: Option) {
        switch option {
        case .settings:
            guard let controller = profilebar?.controller,
                let nav = controller.storyboard?.instantiateViewController(withIdentifier: "setnav") as? UINavigationController,
                let vc = nav.viewControllers.first as? SettingsViewController
            else { return }
            
            switch controller {
            case is NowPlayingViewController: controller.performSegue(withIdentifier: "settings", sender: controller)
            case is QueueViewController: vc.mode = .queue; fallthrough
            default:
                vc.closebutton = nil
                controller.show(vc, sender: controller)
            }
            
        case .friendRequests:
            disappear()
            profilebar?.controller.performSegue(withIdentifier: "social", sender: profilebar?.controller)
        
        case .checkFrequencies:
            disappear() //TODO: disappear hides cover inappropriately here
            gm?.view(frequencies: ())
            
        case .shareQueue:
            disappear()
            guard let controller = profilebar?.controller as? QueueViewController else { return }
            controller.manager?.view(listeners: ())
        
        case .shuffle: Settings.shuffle = !Settings.shuffle
            
        case .addSong:
            disappear()
            guard let controller = profilebar?.controller as? QueueViewController else { return }
            controller.performSegue(withIdentifier: "search", sender: controller)
        
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
        
        case .removePlaylist:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .library else { return }
            if controller.manager?.client().library.isEmpty ?? true { return }
            controller.edit(controller)
        
        case .joinQueue:
            disappear()
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .library,
                let user = CliqueAPI.find(user: controller.user) else { return }
            if user == q.manager?.client() { gm?.stop(listening: ()) }
            else { gm?.listen(to: user.id) }
        
        case .addUser:
            guard let controller = profilebar?.controller as? BrowseViewController,
                controller.mode == .library else { return }
            gm?.add(friend: controller.user)
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
            
        case .addHistoryPlaylist:
            guard let controller = profilebar?.controller as? QueueViewController,
                controller.mode == .history,
                let leader = controller.manager?.client(),
                let me = CliqueAPI.find(user: Identity.me) else { return }
            
            let songs = q.manager?.client().queue.history
            var id = 0
            while (me.library.map { $0.id }).contains(id.description) { id += 1 }
            let df = DateFormatter()
            df.dateFormat = "M-d"
            let date = df.string(from: Date())
            
            let playlist = Playlist(
                owner: me.id,
                id: id.description,
                library: Catalogues.Library.rawValue,
                name: leader.me() ? "session " + date : "collab with @" + leader.username,
                social: true,
                songs: songs ?? []
            )
            bro.manager?.add(playlist: playlist)
            
            disappear()
            
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
        
        profilebar?.display(subline: profilebar?.message ?? .generic)
    }
    
}
