//
//  Actions.swift
//  Clique
//
//  Created by Phil Hawkins on 5/12/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Actions {
    
    //MARK: - properties
    
    static var controller: UIViewController?
    
    static var playlist: Playlist?
    static var queue: Queue?
    static var song: Song?
    static var index: Int?
    static var user: User?
    
    //MARK: - factory
    
    private static func actions(_ actions: Action...) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        if let playlist = playlist, song == nil, user == nil {
            let count = playlist.songs.count
            alert.title = playlist.name
            alert.message = count == 1 ? count.description + " song" : count.description + " songs"
        } else if let song = song, user == nil {
            alert.title = song.title
            alert.message = song.artist.name
        } else if let user = user {
            alert.title = "@" + user.username
            if let current = user.queue.current { alert.message = "🔊" + current.artist.name + " - " + current.title }
        }
        
        for action in actions {
            var title = ""
            
            switch action {
            case .viewPlaylist: title = "view playlist"
            case .playPlaylist, .playSong, .playSingle: title = "play"
            case .skipToSong: title = "skip to this song"
            case .addToLibrary: title = "add playlist to library"
            case .addToLikes: title = "add to likes"
            case .addToPlaylist: title = "add to a playlist..."
            case .nowPlaying: title = "now playing"
            case .upvote: title = "+ upvote"
            case .downvote: title = "- downvote"
            case .addToQueue, .addSingleToQueue: title = "add to queue"
            case .request: title = "request"
            case .send: title = "send to a friend..."
            case .viewArtist: title = "view " + (song?.artist.name ?? "")
            case .addToFriends: title = "add friend"
            case .viewUser:
                let viewing = "@" == alert.title?.first
                title = viewing ? "view library" : song == nil ? "view owner" : "view sender"
            case .joinQueue:
                guard let user = user else { break }
                let listening = !user.me() && user == q.manager?.client()
                title = listening ? "stop listening" : "join queue"
            }
            
            let act = UIAlertAction(title: title, style: .default) { _ in execute(action) }
            alert.addAction(act)
        }
        
        if alert.actions.count < 2 { alert.addAction(UIAlertAction(title: "continue", style: .default)) }
        
        alert.addAction(UIAlertAction(title: "nevermind", style: .cancel))
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    static func friends() -> UIAlertController {
        let alert = UIAlertController(title: "send to:", message: nil, preferredStyle: .alert)
        guard let song = song, let me = CliqueAPI.find(user: Identity.me) else { return alert }
        
        for friend in me.friends {
            guard let friend = CliqueAPI.find(user: friend) else { continue }
            
            let act = UIAlertAction(title: "@" + friend.username, style: .default) { _ in
                gm?.send(song: song, to: friend)
            }
            
            if alert.actions.count == 1 { alert.addAction(UIAlertAction(title: "continue", style: .default)) }
            
            alert.addAction(act)
        }
        
        alert.addAction(UIAlertAction(title: "nevermind", style: .cancel))
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    static func playlists() -> UIAlertController {
        let alert = UIAlertController(title: "select playlist", message: nil, preferredStyle: .alert)
        guard let song = song, let me = bro.manager?.client() else { return alert }
        
        for playlist in me.library {
            if playlist.owner != Identity.me || playlist.library != Catalogues.Library.rawValue { continue }
            
            let act = UIAlertAction(title: playlist.name, style: .default) { _ in
                var playlist = playlist
                playlist.songs.append(song)
                bro.manager?.update(playlist: playlist)
            }
            
            alert.addAction(act)
        }
        
        if alert.actions.count == 1 { alert.addAction(UIAlertAction(title: "continue", style: .default)) }
        
        alert.addAction(UIAlertAction(title: "nevermind", style: .cancel))
        alert.view.tintColor = UIColor.orange
        
        return alert
    }
    
    //MARK: - methods
    
    static func execute(_ action: Action) {
        switch action {
        case .viewPlaylist:
            guard let playlist = playlist, let controller = controller as? BrowseViewController else { return }
            controller.manager?.view(playlist: playlist)
        case .playPlaylist:
            guard let playlist = playlist, let controller = controller as? BrowseViewController else { return }
            controller.manager?.play(playlist: playlist, at: 0)
        case .addToLibrary:
            guard let playlist = playlist else { return }
            CliqueAPI.update(playlist: Identity.me, with: playlist)
        case .nowPlaying:
            swipe?.selectedViewController = swipe?.viewControllers?[1]
        case .playSong:
            switch controller {
            case let controller as BrowseViewController:
                switch controller.mode {
                case .playlist, .browse, .search, .catalog,
                     _ where controller.manager?.delegate?.searching ?? false:
                    guard let playlist = playlist, let index = index else { return }
                    //controller.dismiss(animated: true)
                    controller.manager?.play(playlist: playlist, at: index)
                    
                default: return
                }
            case let controller as QueueViewController:
                guard let song = song else { return }
                controller.manager?.play(song: song)
            default: return
            }
        case .playSingle:
            guard let song = song else { return }
            let single = Single(title: song.title, artist: song.artist.name)
            q.manager?.play(single: single)
            case .skipToSong:
            guard let song = song, var queue = q.manager?.client().queue else { return }
            while let next = queue.queue.first, song != next { queue.queue.remove(at: 0) }
            queue.queue.remove(at: 0)
            q.manager?.update(queue: queue)
            q.manager?.play(song: song)
        case .addToLikes:
            guard let song = song else { return }
            var likes = bro.manager?.client().library.filter({ $0.id == "0" }).first ??
                Playlist(
                    owner: Identity.me,
                    id: "0",
                    library: Catalogues.Library.rawValue,
                    name: "likes",
                    social: true,
                    songs: []
            )
            likes.songs.append(song)
            bro.manager?.update(playlist: likes)
        case .addToPlaylist:
            guard let _ = song, let controller = controller else { return }
            let alert = playlists()
            controller.present(alert, animated: true)
        case .upvote:
            guard let song = song, let controller = controller as? QueueViewController else { return }
            q.manager?.vote(song: song, .up)
            if let index = index,
                let cell = controller.table?.cellForRow(at: IndexPath(row: index, section: 1)) as? QueueSongTableViewCell,
                let votes = cell.voteslabel.text,
                var count = Int(votes) {
                count += 1
                cell.voteslabel.text = count.description
            }
        case .downvote:
            guard let song = song, let controller = controller as? QueueViewController else { return }
            q.manager?.vote(song: song, .down)
            if let index = index,
                let cell = controller.table?.cellForRow(at: IndexPath(row: index, section: 1)) as? QueueSongTableViewCell,
                let votes = cell.voteslabel.text,
                var count = Int(votes) {
                count -= 1
                cell.voteslabel.text = count.description
            }
        case .addToQueue, .request:
            guard let song = song else { return }
            q.manager?.add(song: song)
        case .addSingleToQueue:
            guard let index = index, let controller = controller as? QueueViewController else { return }
            q.manager?.add(single: q.radio[index])
            q.radio.remove(at: index)
        case .send:
            guard let _ = song, let controller = controller else { return }
            let alert = friends()
            controller.present(alert, animated: true)
        case .viewArtist:
            switch controller {
            case is BrowseViewController, is QueueViewController:
                guard let song = song, let vc = controller?.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
                    else { return }
                
                vc.final = false
                vc.adding = false
                vc.navigationItem.prompt = nil
                vc.user = Identity.me
                vc.mode = .catalog
                vc.catalog = song.artist
                
                //controller?.dismiss(animated: true)
                controller?.show(vc, sender: controller)
            default: return
            }
        case .viewUser:
            switch controller {
            case let controller as BrowseViewController:
                guard let user = user else { return controller.manager?.view(user: song?.sender ?? playlist?.owner ?? "") ?? () }
                controller.manager?.view(user: user.id)
            case let controller as QueueViewController:
                guard let vc = controller.storyboard?.instantiateViewController(withIdentifier: VCid.bro.rawValue) as? BrowseViewController
                    else { return }
                
                vc.final = false
                vc.adding = false
                vc.navigationItem.prompt = nil
                vc.user = user?.id ?? song?.sender ?? playlist?.owner ?? ""
                vc.mode = .library
                
                //controller.dismiss(animated: true)
                controller.show(vc, sender: controller)
            default: return
            }
        case .addToFriends:
            guard let user = user else { return }
            gm?.add(friend: user.id)
        case .joinQueue:
            guard let user = user else { return }
            if user == q.manager?.client() { gm?.stop(listening: ()) }
            else { gm?.listen(to: user.id) }
        }
    }
    
    static func view(nowplaying song: Song, on controller: UIViewController) {
        let alert: UIAlertController
        
        self.controller = controller
        self.song = song
        playlist = nil
        queue = nil
        index = nil
        user = nil
        
        alert = actions(.nowPlaying, .addToLikes, .addToPlaylist)
        controller.present(alert, animated: true)
    }
    
    static func view(playlist: Playlist, on controller: UIViewController) {
        let alert: UIAlertController
        
        self.controller = controller
        self.playlist = playlist
        song = nil
        queue = nil
        index = nil
        user = nil
        
        switch controller {
        case let controller as BrowseViewController:
            alert = playlist.owner == Identity.me ?
                actions(.viewPlaylist, .playPlaylist) :
                controller.mode == .library && controller.user == Identity.me ?
                    actions(.viewPlaylist, .playPlaylist, .viewUser) :
                    actions(.viewPlaylist, .playPlaylist, .addToLibrary)
            
        default: return
        }
        
        controller.present(alert, animated: true)
    }
    
    static func view(song index: Int, in playlist: Playlist, on controller: UIViewController) {
        guard index < playlist.songs.count else { return }
        let alert: UIAlertController
        
        self.controller = controller
        self.song = playlist.songs[index]
        self.playlist = playlist
        self.index = index
        queue = nil
        user = nil
        
        let leader = q.manager?.client()
        let me = leader?.me() ?? false
        let requestsonly = leader?.queue.requestsonly ?? false
        
        switch controller {
        case is BrowseViewController where requestsonly && me:
            alert = actions(.playSong, .request, .addToLikes, .addToPlaylist, .send)
        case is BrowseViewController:
            alert = actions(.playSong, .addToQueue, .addToLikes, .addToPlaylist, .send)
        default: return
        }
        
        controller.present(alert, animated: true)
    }
    
    static func view(song index: Int, in queue: Queue, on controller: UIViewController) {
        let alert: UIAlertController
        self.controller = controller
        self.queue = queue
        self.index = index
        song = queue.queue[index]
        user = nil
        
        let leader = q.manager?.client()
        let me = leader?.me() ?? false
        let collab = song!.sender != Identity.me && leader?.friends.contains(song!.sender) ?? false
        
        switch controller {
        case is QueueViewController where me && collab:
            alert = actions(.skipToSong, .addToLikes, .addToPlaylist, .upvote, .downvote, .send, .viewUser)
        case is QueueViewController where me:
            alert = actions(.skipToSong, .addToLikes, .addToPlaylist, .upvote, .downvote, .send)
        case is QueueViewController:
            alert = actions(.addToLikes, .addToPlaylist, .upvote, .downvote, .send)
        default: return
        }
        
        controller.present(alert, animated: true)
    }
    
    static func view(single index: Int, on controller: UIViewController) {
        let alert: UIAlertController
        
        self.controller = controller
        self.song = q.radio[index].info
        self.index = index
        playlist = nil
        queue = nil
        user = nil
        
        alert = actions(.playSingle, .addSingleToQueue)
        controller.present(alert, animated: true)
    }
    
    static func view(song: Song, on controller: UIViewController) {
        let alert: UIAlertController
        
        self.controller = controller
        self.song = song
        playlist = nil
        queue = nil
        index = nil
        user = nil
        
        let leader = q.manager?.client()
        let me = leader?.me() ?? false
        let requestsonly = leader?.queue.requestsonly ?? false
        let collab = song.sender != Identity.me && leader?.friends.contains(song.sender) ?? false
        
        switch controller {
        case is BrowseViewController where requestsonly && me:
            alert = actions(.playSong, .request, .addToLikes, .addToPlaylist, .send)
        case is BrowseViewController:
            alert = actions(.playSong, .addToQueue, .addToLikes, .addToPlaylist, .send)
            
        case is NowPlayingViewController: alert = actions(.addToLikes, .addToPlaylist)
        
        case is QueueViewController where collab:
            alert = actions(.playSong, .addToQueue, .addToLikes, .addToPlaylist, .send, .viewUser)
        case is QueueViewController:
            alert = actions(.playSong, .addToQueue, .addToLikes, .addToPlaylist, .send)
            
        default: return
        }
        
        controller.present(alert, animated: true)
    }
    
    static func view(user: User, on controller: UIViewController) {
        let alert: UIAlertController
        
        self.controller = controller
        self.user = user
        playlist = nil
        queue = nil
        index = nil
        song = nil
        
        let friends = user.friends.contains(Identity.me)
        
        switch controller {
        case is BrowseViewController:
            alert = friends ?
                actions(.viewUser, .joinQueue) :
                actions(.viewUser, .addToFriends)
        
        default: return
        }
        
        controller.present(alert, animated: true)
    }
    
}
