//
//  Alerts.swift
//  Clique
//
//  Created by Phil Hawkins on 1/10/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Alerts {
    
    //MARK: - factory
    
    private static func confirm(title: String? = nil, message: String? = nil, action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "continue", style: .default) { action?($0) })
        alert.addAction(UIAlertAction(title: "nevermind", style: .default))
        
        alert.view.tintColor = UIColor.orange
        alert.preferredAction = alert.actions.last
        
        return alert
    }
    
    private static func inform(title: String? = nil, messsage: String? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: title, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ok", style: .cancel))
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    private static func input(title: String? = nil, message: String? = nil, entry: String? = nil, placeholder: String? = nil, action: ((_ action: UIAlertAction, _ controller: UIAlertController) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { $0.text = entry }
        alert.textFields?.first?.placeholder = placeholder
        
        alert.addAction(UIAlertAction(title: "continue", style: .default) { act in
            action?(act, alert)
        })
        alert.addAction(UIAlertAction(title: "nevermind", style: .cancel))

        
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    //MARK: - alerts
    
    static func add(friend: User, on controller: BrowseViewController) {
        let alert = confirm(title: "add friend", message: "@" + friend.username + " will be able to see your queue") { _ in
            controller.manager?.find(friend: friend, confirmed: true)
        }
        
        controller.present(alert, animated: true)
    }
    
    static func add(playlist: Void, on controller: BrowseViewController) {
        let alert = UIAlertController(title: "add playlist", message: "add a playlist to your library", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "sync playlist", style: .default) { action in
            bro.manager?.view(sync: ())
        })
        alert.addAction(UIAlertAction(title: "create new playlist", style: .default) { action in
            create(playlist: (), on: controller)
        })
        alert.addAction(UIAlertAction(title: "nevermind", style: .cancel))
        
        alert.view.tintColor = UIColor.orange
        
        controller.present(alert, animated: true)
    }
    
    static func create(playlist: Void, on controller: BrowseViewController) {
        controller.dismiss(animated: true)
        
        let alert = input(title: "new playlist", placeholder: "playlist name") { (action, alert) in
            var id = 0
            while !(controller.manager?.client().library.filter { $0.id == id.description } ?? []).isEmpty {
                id += 1
            }
            
            let new = Playlist(
                owner: Identity.me,
                id: id.description,
                library: Catalogues.Library.rawValue,
                name: alert.textFields?.first?.text ?? "",
                social: true,
                songs: []
            )
            
            controller.manager?.add(playlist: new)
            controller.manager?.view(playlist: new)
        }
        
        controller.present(alert, animated: true)
    }
    
    static func delete(friend: User, on controller: BrowseViewController) {
        let alert = confirm(title: "unfriend", message: "@" + friend.username + " will not be able to see your queue") { _ in
            controller.manager?.delete(friend: friend, confirmed: true)
        }
        
        controller.present(alert, animated: true)
    }
    
    static func delete(queue: Void, on controller: QueueViewController) {
        let alert = confirm(title: "clear queue", message: "all songs in up next will be deleted") { _ in
            controller.manager?.delete(queue: (), confirmed: true)
        }
        
        controller.present(alert, animated: true)
    }
    
    static func delete(requests: Void, on controller: QueueViewController) {
        let alert = confirm(title: "clear requests", message: "all requests will be deleted") { _ in
            controller.manager?.delete(requests: (), confirmed: true)
        }
        
        controller.present(alert, animated: true)
    }
    
    static func inform(_ event: Inform, about user: User? = nil) {
        var title = ""
        var message = ""
        
        switch event {
        case .userNotFound: break
        case .doNotDisturb: break
        case .noAccount: break
        case .stopListening: break
        case .notFriends: break
        case .canNotQueueSong: break
        }
    }
    
    static func invite(friend: User, on controller: QueueViewController) {
        let alert = confirm(title: "invite friend", message: "ask @" + friend.username + " to join the queue") { _ in
            controller.manager?.invite(friend: friend, confirmed: true)
        }
        
        controller.present(alert, animated: true)
    }
    
    static func kill(on controller: SettingsViewController) {
        let username = controller.profilebar.client?.username ?? ""
        
        let alert = UIAlertController(title: "delete @" + username, message: "friends, playlists, and queue history will be permanently deleted", preferredStyle: .alert)
        alert.view.tintColor = UIColor.orange
        
        alert.addAction(UIAlertAction(title: "nevermind", style: .cancel))
        alert.addAction(UIAlertAction(title: "delete user", style: .destructive) { act in
            controller.kill(confirmed: true)
        })
        
        controller.present(alert, animated: true)
    }
    
    static func respond(to request: Request, on controller: UIViewController?, friends: Bool) {
        guard let sender = CliqueAPI.find(user: request.sender) else { return }
        let title = friends ? "listen with @" + sender.username : "@" + sender.username + " added you"
        let message = friends ? "@" + sender.username + " invited you to their queue" : "add @" + sender.username + " to share with them"
        let affirm = friends ? "join queue" : "add friend"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = UIColor.orange
        
        alert.addAction(UIAlertAction(title: affirm, style: .default) { act in
            gm?.respond(to: request, confirmed: true, affirmed: true)
        })
        alert.addAction(UIAlertAction(title: "delete request", style: .destructive) { act in
            gm?.respond(to: request, confirmed: true)
        })
        
        controller?.present(alert, animated: true)
    }
    
    static func sync(playlist: Void, on controller: BrowseViewController) {
        controller.dismiss(animated: true)
        
        let alert = confirm(title: "sync " + controller.playlist.name, message: "update all songs in playlist") { _ in
            controller.manager?.sync(confirmed: true)
        }
        
        controller.present(alert, animated: true)
    }
    
    static func queue(song: Song, on controller: BrowseViewController) {
        let leader = q.manager?.client()
        let requestsonly = leader?.queue.requestsonly ?? false
        let title = requestsonly ? "request song" : "add song"
        let message = song.title + " by " + song.artist.name + (requestsonly ?
            " will be added to requests" :
            " will be added to to the queue")
        let alert = confirm(title: title, message: message) { _ in
            q.manager?.find(song: song, from: controller, confirmed: true)
        }
        
        //controller.dismiss(animated: true)
        controller.present(alert, animated: true)
    }
    
    static func rename(user profile: ProfileBar, on controller: UIViewController, retry: Bool = false) {
        guard let user = profile.client else { return }
        
        let alert = input(title: "", entry: user.username) { (action, alert) in
            guard let name = alert.textFields?.first?.text else { return }
            if name == user.username { return }
            
            let matches = CliqueAPI.search(user: name, strict: true)
            
            if matches.isEmpty || name == "anonymous" {
                CliqueAPI.update(username: user.id, to: name)
                profile.display(username: name)
            } else { rename(user: profile, on: controller, retry: true) }
        }
        
        if retry { alert.message = "that name is already taken" }
        controller.present(alert, animated: true)
    }
    
}
