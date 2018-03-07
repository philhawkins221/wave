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
    private var friends = Identity.sharedInstance().friends
    var controller: NowPlayingViewController
    var display: Song?
    
    //MARK: - initializers
    
    init?(to controller: NowPlayingViewController) {
        guard let found = CliqueAPI.find(user: Identity.sharedInstance().me) else { return nil }
        
        self.user = found
        self.controller = controller
        
        update()
    }
    
    //MARK: - mutators
    
    mutating func manage(user: User) {
        self.user = user
        controller.profilebar.manage(profile: user)
    }
    
    mutating func manage(display: Song?) {
        self.display = display
    }
    
    mutating func update(with replacement: User? = nil) {
        if let replacement = replacement {
            CliqueAPI.update(user: replacement)
        }
        
        refresh()
    }
    
    private mutating func refresh() {
        guard let found = CliqueAPI.find(user: user.id) else { return }
        
        manage(user: found)
        manage(display: user.queue.current)
        nowplaying()
    }
    
    //MARK: - actions
    
    func nowplaying() {
        guard let song = display else { return notplaying() }
        
        controller.artworkimage.isHidden = false
        controller.songlabel.isHidden = false
        controller.artistlabel.isHidden = false
        controller.albumlabel.isHidden = false
        if user.me() {
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
}
