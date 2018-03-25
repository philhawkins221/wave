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
    
    private var user: User
    var controller: NowPlayingViewController
    var display: Song?
    
    //MARK: - initializers
    
    init?(to controller: NowPlayingViewController) {
        guard let found = CliqueAPI.find(user: Identity.me) else { return nil }
        
        self.user = found
        self.controller = controller
        
        display = user.queue.current
        nowplaying()
        
        controller.profilebar.manage(profile: user)
    }
    
    //MARK: - tasks
    
    func add(friend: String) {
        CliqueAPI.add(friend: friend, to: user.id)
    }
    
    func connect(applemusic status: Bool) {
        CliqueAPI.update(applemusic: user.id, to: status)
    }
    
    func connect(spotify status: Bool) {
        CliqueAPI.update(spotify: user.id, to: status)
    }
    
    func delete(friend: String) {
        CliqueAPI.delete(friend: friend, for: user.id)
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
        
        controller.profilebar.display(subline: .nowPlaying)
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
    
}
