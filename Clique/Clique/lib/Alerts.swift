//
//  Alerts.swift
//  Clique
//
//  Created by Phil Hawkins on 1/10/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Alerts {
    
    static func textField(title: String? = nil, message: String? = nil, entry: String? = nil, placeholder: String? = nil, action: ((_ action: UIAlertAction, _ controller: UIAlertController) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { $0.text = entry }
        alert.textFields?.first?.placeholder = placeholder
        
        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { act in
            action?(act, alert)
        })
        
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    static func confirmation(title: String? = nil, message: String? = nil, entry: String? = nil, action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { action?($0) })
        
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    static func libraryAdd() -> UIAlertController {
        let alert = UIAlertController(title: "Add Playlist", message: "Add a playlist to your Library", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Create New Playlist", style: .default) { action in
            //collect name
            let alert = textField(title: "New Playlist", placeholder: "Playlist Name") { (action, alert) in
                var id = 0
                
                while !(bro.manager?.client().library.filter({ $0.id == id.description }) ?? []).isEmpty {
                    id += 1
                }
                
                let new = Playlist(
                    owner: Identity.sharedInstance().me,
                    id: id.description,
                    library: Catalogues.Library.rawValue,
                    name: alert.textFields?.first?.text ?? "",
                    social: true,
                    songs: [])
                
                bro.manager?.add(playlist: new)
                bro.manager?.view(playlist: new)
            }
            
            bro.manager?.controller.present(alert, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Add Existing Playlist", style: .default) { action in
            bro.manager?.viewSyncPlaylists()
        })
        alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel))
        
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
}
