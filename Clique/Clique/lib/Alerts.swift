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
    
    private static func confirm(title: String? = nil, message: String? = nil, action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "continue", style: .default) { action?($0) })
        alert.addAction(UIAlertAction(title: "nevermind", style: .default))

        alert.view.tintColor = UIColor.orange
        alert.preferredAction = alert.actions.last
        
        return alert
    }
    
    //MARK: - tasks
    
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
    
    static func sync(playlist: Void, on controller: BrowseViewController) {
        controller.dismiss(animated: true)
        
        let alert = confirm(title: "sync " + controller.playlist.name, message: "update all songs in playlist") { _ in
            controller.manager?.sync()
        }
        
        controller.present(alert, animated: true)
    }
    
    static func queue(song: Song) {
        q.dismiss(animated: true)
        if q.manager?.client().me() ?? false { return q.manager!.find(song: song) }
        
        let alert = confirm(title: "add song", message: "add " + song.title + " to the queue") { _ in
            q.manager?.find(song: song)
        }
        
        q.present(alert, animated: true)
    }
    
    static func rename(user profile: ProfileBar, on controller: UIViewController) {
        guard var replacement = profile.client else { return }
        
        let alert = input(title: "", entry: replacement.username) { (action, alert) in
            guard let name = alert.textFields?.first?.text else { return }
            replacement.username = name
            
            CliqueAPI.update(user: replacement)
            profile.display(username: name)
        }
        
        controller.present(alert, animated: true)
    }
    
}
