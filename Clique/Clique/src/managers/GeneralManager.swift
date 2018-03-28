//
//  GeneralManager.swift
//  Clique
//
//  Created by Phil Hawkins on 1/20/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct GeneralManager {
    
    //MARK: - properties
    
    private var me: User
    var controller: NowPlayingViewController
    var display: Song? { return q.manager?.client().queue.current }
    
    //MARK: - initializers
    
    init?(to controller: NowPlayingViewController) {
        guard let found = CliqueAPI.find(user: Identity.me) else { return nil }
        
        self.me = found
        self.controller = controller
        
        nowplaying()
        
        controller.profilebar.manage(profile: me)
        check(frequencies: ())
    }
    
    //MARK: - tasks
    
    func add(friend: User) {
        CliqueAPI.add(friend: friend.id, to: me.id)
        CliqueAPI.request(friend: Request(sender: me.id, receiver: friend.id))
    }
    
    func check(frequencies: Void, cached: Bool = true) {
        let user = cached ? self.me : CliqueAPI.find(user: self.me.id) ?? self.me
        var frequencies = [User]()
        
        for friend in user.friends {
            guard let friend = CliqueAPI.find(user: friend) else { continue }
            if friend.queue.current != nil { frequencies.append(friend) }
        }
        
        controller.frequencies = frequencies
    }
    
    func check(requests: Void, cached: Bool = true) -> Bool {
        return cached ? me.requests.isEmpty : !(CliqueAPI.find(user: me.id)?.requests.isEmpty ?? true)
    }
    
    func connect(applemusic status: Bool) {
        CliqueAPI.update(applemusic: me.id, to: status)
    }
    
    func connect(spotify status: Bool) {
        CliqueAPI.update(spotify: me.id, to: status)
    }
    
    func delete(friend: String) {
        CliqueAPI.delete(friend: friend, for: me.id)
    }
    
    func listen(to user: String) {
        guard let user = CliqueAPI.find(user: user) else { return }
        
        q.manager?.stop()
        CliqueAPI.add(listener: me.id, to: user.id)
        q.manager?.manage(user: user)
        //TODO: swipe to q
    }
    
    func nowplaying() {
        guard let song = display else { return notplaying() }
        
        controller.artworkimage.isHidden = false
        controller.songlabel.isHidden = false
        controller.artistlabel.isHidden = false
        controller.albumlabel.isHidden = false
        
        if q.manager?.client().me() ?? false {
            controller.rewindbutton.isHidden = false
            controller.fastforwardbutton.isHidden = false
        } else {
            controller.rewindbutton.isHidden = true
            controller.fastforwardbutton.isHidden = true
        }
        
        controller.playpausebutton?.isHidden = false
        controller.playpausebutton?.isPaused = false
        
        controller.songlabel.text = song.title
        controller.artistlabel.text = song.artist.name
        controller.albumlabel.text = nil
        
        if song.library == Catalogues.Library.rawValue {
            controller.artworkimage.image = Media.get(artwork: song.id) ?? UIImage(named: "genericart.png")
        } else {
            let url = URL(string: song.artwork) ?? URL(string: "/")!
            controller.artworkimage.af_setImage(withURL: url, placeholderImage: UIImage(named: "genericart.png"))
        }
        
    }
    
    private func notplaying() {
        print("notplaying")
        controller.artworkimage.isHidden = true
        controller.songlabel.isHidden = true
        controller.artistlabel.isHidden = true
        controller.albumlabel.isHidden = true
        controller.rewindbutton.isHidden = true
        controller.fastforwardbutton.isHidden = true
        
        controller.playpausebutton?.isHidden = false
        controller.playpausebutton?.isPaused = true
        
        controller.profilebar.display(subline: .generic)
    }
    
    func refresh() {
        controller.refresh()
    }
    
    func stop(listening: Void) {
        guard let leader = q.manager?.client() else { return }
        let replacement = leader.queue.listeners.filter { $0 != Identity.me }
        CliqueAPI.update(listeners: replacement, for: leader.id)
        q.manager?.manage(user: me)
        notplaying()
    }
    
    func stop(sharing: Void) {
        CliqueAPI.update(listeners: [], for: Identity.me)
        q.manager?.stop()
        notplaying()
    }
    
}
