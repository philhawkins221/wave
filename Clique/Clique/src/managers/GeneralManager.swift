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
    
    ///the end user's information (cached)
    private var me: User
    ///the now playing view controller
    var controller: NowPlayingViewController
    ///the song displaying now playing info, nil if no song currently playing
    var display: Song? { return q.manager?.client().queue.current }
    
    //MARK: - initializers
    
    /**
     initializes the general manager for now playing and pulls the end user from server with the end user identity. fails if a valid user cannot be found with the user id provided.
     
     - parameters:
        - controller: the controller displaying the user's information
     */
    init?(to controller: NowPlayingViewController) {
        guard let found = CliqueAPI.find(user: Identity.me) else { return nil }
        
        self.me = found
        self.controller = controller
        
        nowplaying()
        
        controller.profilebar.manage(profile: me)
        check(frequencies: ())
    }
    
    //MARK: - tasks
    
    /**
     add a given user to friends.
     
     - parameters:
        - friend: the id of the user to add to friends
    */
    func add(friend: String) {
        CliqueAPI.add(friend: friend, to: me.id)
        request(user: friend)
    }
    
    ///tells the queue manager to advance.
    ///- note: queue manager client must match end user identity
    func advance() {
        guard q.manager?.client().me() ?? false else { return }
        q.refresh()
        q.manager?.advance()
    }
    
    /**
     checks if any friends are sharing.
     
     - parameters:
        - frequencies: _
        - cached: if the manager should use the cached user information, default value is `true`
    */
    func check(frequencies: Void, cached: Bool = true) {
        let user = cached ? self.me : CliqueAPI.find(user: self.me.id) ?? self.me
        var frequencies = [User]()
        
        for friend in user.friends {
            guard let friend = CliqueAPI.find(user: friend) else { continue }
            if friend.queue.current != nil && !friend.queue.donotdisturb { frequencies.append(friend) }
        }
        
        controller.frequencies = frequencies
    }
    
    /**
     checks for new requests.
     
     - parameters:
        - requests: _
        - cached: if the manager should use the cached user information, default value is `true`
     */
    func check(requests: Void, cached: Bool = true) -> Bool {
        return cached ? me.requests.isEmpty : !(CliqueAPI.find(user: me.id)?.requests.isEmpty ?? true)
    }
    
    /**
     sets the connected status for Apple Music.
     
     - parameters:
        - status: if Apple Music is connected
    */
    func connect(applemusic status: Bool) {
        if status, Settings.applemusic { guard Media.authenticate() else { return } }
        if !status, Settings.applemusic { Settings.radio = status }
        
        CliqueAPI.update(applemusic: me.id, to: status)
    }
    
    /**
     sets the connected status for Spotify.
     
     - parameters:
        - status: if Spotify is connected
     */
    func connect(spotify status: Bool) {
        if status, Settings.spotify {
            guard Spotify.authenticate() else { return }
        }
        
        CliqueAPI.update(spotify: me.id, to: status)
    }
    
    /**
     delete a user from friends.
     
     - parameters:
        - friend: the user id of the friend to delete
    */
    func delete(friend: String) {
        CliqueAPI.delete(friend: friend, for: me.id)
    }
    
    ///determines display for the help label.
    func help() {
        controller.helplabel.text = nil
        
        switch q.manager?.status ?? .none {
        case .streaming where !Media.playing: controller.helplabel.text = "press play to start streaming"
        default: return
        }
        
        controller.helplabel.alpha = 0
        controller.helplabel.isHidden = false
        
        UIView.animate(withDuration: 0.2) { self.controller.helplabel.alpha = 1 }
    }
    
    /**
     hides the tuner.
     
     - parameters:
        - frequencies: _
    */
    func hide(frequencies: Void) {
        UIView.animate(withDuration: 0.15, delay: 0, animations: {
            self.controller.tuner.alpha = 0
        }, completion: { _ in
            self.controller.tuner.isHidden = true
            self.controller.optionscover.gestureRecognizers?.forEach { self.controller.optionscover.removeGestureRecognizer($0) }
            self.controller.optionscover.isHidden = true
        })
    }
    
    /**
     join a given user's queue.
     
     - parameters:
     - user: the id of the user to join
     - redirect: if the swipe controller will automatically redirect to the queue, default value is `true`
    */
    func listen(to user: String, redirect: Bool = true) {
        guard q.manager?.client().id != user else { return }
        guard let user = CliqueAPI.find(user: user) else { return Alerts.inform(.userNotFound) }
        guard user.friends.contains(Identity.me) else { return Alerts.inform(.notFriends, about: user) }
        guard !user.queue.donotdisturb else { return Alerts.inform(.doNotDisturb) }
        
        if let leader = q.manager?.client() {
            if leader.me() { stop(sharing: ()) }
            else { stop(listening: ()) }
        }
        if !user.queue.listeners.contains(Identity.me) { CliqueAPI.add(listener: me.id, to: user.id) }
        q.manager?.manage(user: user)
        
        guard redirect else { return }
        bro.navigationController?.popToRootViewController(animated: true)
        swipe?.selectedViewController = swipe?.viewControllers?[2]
        controller.dismiss(animated: true)
    }
    
    ///sets now playing display for current song.
    func nowplaying() {
        guard let song = display else { return notplaying() }
        let placeholder = #imageLiteral(resourceName: "genericart.png")
        controller.artworkimage.image = placeholder
        controller.helplabel.text = nil
        
        controller.waves.isHidden = true
        
        controller.artworkimage.isHidden = false
        controller.songlabel.isHidden = false
        controller.artistlabel.isHidden = false
        controller.creditlabel.isHidden = false
        
        if q.manager?.client().me() ?? false {
            controller.rewindbutton.isHidden = false
            controller.fastforwardbutton.isHidden = false
        } else {
            controller.rewindbutton.isHidden = true
            controller.fastforwardbutton.isHidden = true
        }
        
        controller.playpausebutton?.isHidden = false
        controller.playpausebutton?.isPaused = Media.playing && Media.paused || !Media.playing && !Spotify.playing
        
        controller.songlabel.text = song.title
        controller.artistlabel.text = song.artist.name
        
        if song.sender == "1" { controller.creditlabel.text = "from: wave radio" }
        else if song.sender != "", song.sender != "1", song.sender != Identity.me, let sender = CliqueAPI.find(user: song.sender)
            { controller.creditlabel.text = "from: @" + sender.username }
        else { controller.creditlabel.text = nil }
        
        controller.artworkimage.contentMode = .scaleAspectFit
        
        if let url = URL(string: song.artwork) {
            controller.artworkimage.af_setImage(withURL: url, placeholderImage: placeholder, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: false)
        } else if let url = URL(string: iTunesAPI.match(song)?.artwork ?? "") {
            controller.artworkimage.af_setImage(withURL: url, placeholderImage: placeholder, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: false)
        }
        
        help()
    }
    
    ///sets now playing display when no song is playing.
    private func notplaying() {
        controller.artworkimage.isHidden = true
        controller.songlabel.isHidden = true
        controller.artistlabel.isHidden = true
        controller.creditlabel.isHidden = true
        controller.rewindbutton.isHidden = true
        controller.fastforwardbutton.isHidden = true
        
        controller.waves.isHidden = false
        controller.playpausebutton?.isHidden = false
        controller.playpausebutton?.isPaused = true
        
        controller.profilebar.display(subline: .generic)
        
        help()
    }
    
    ///updates the user's information from server.
    ///- note: this manager will be deinitialized
    func refresh() {
        controller.refresh()
    }
    
    /**
     sends a friend request to a given user/invite to a friend.
     
     - parameters:
        - user: the user id of the user receiving the request
    */
    func request(user: String) {
        let request = Request(sender: me.id, receiver: user)
        CliqueAPI.request(friend: request)
    }
    
    /**
     opens a given request.
     
     - note: `request` receiver must match end user identity
     - parameters:
        - request: the request to open
        - confirmed: if the task was confirmed by the end user, default value is `false`
        - affirmed: if the request was accepted by the end user, default value is `false`
    */
    func respond(to request: Request, confirmed: Bool = false, affirmed: Bool = false) {
        guard request.receiver == Identity.me else { return }
        guard confirmed else {
            let friends = me.friends.contains(request.sender)
            return Alerts.respond(to: request, on: gm?.controller.presentedViewController, friends: friends)
        }
        
        if affirmed && me.friends.contains(request.sender) {
            listen(to: request.sender)
        } else if affirmed {
            add(friend: request.sender)
        }
        
        var replacement = me.requests
        for i in replacement.indices {
            if replacement[i].sender == request.sender {
                replacement.remove(at: i)
                break
            }
        }
        
        CliqueAPI.update(friendRequests: replacement, for: Identity.me)
    }
    
    ///tells the queue manager to retreat.
    ///- note: the queue manager's client must match the end user identity
    func retreat() {
        guard q.manager?.client().me() ?? false else { return }
        q.manager?.retreat()
    }
    
    /**
     adds a given song to a given friend's queue.
     
     - note: `user` must contain the end user in their friends
     - parameters:
        - song: the song to add
        - user: the user with the queue to add the song
    */
    func send(song: Song, to user: User) {
        guard user.friends.contains(Identity.me) else { return }
        guard !user.queue.donotdisturb else { return Alerts.inform(.doNotDisturb) }
        var song = song
        
        song.sender = Identity.me
        return user.queue.requestsonly && !user.me() ?
            CliqueAPI.request(song: song, to: user.id) :
            CliqueAPI.add(song: song, to: user.id)
    }
    
    /**
     leaves the current queue and returns to the end user's queue.
     
     - parameters:
        - listening: _
    */
    func stop(listening: Void) {
        guard let leader = q.manager?.client() else { return }
        let replacement = leader.queue.listeners.filter { $0 != Identity.me }
        CliqueAPI.update(listeners: replacement, for: leader.id)
        q.manager?.stop()
        q.manager?.manage(user: me)
        q.profilebar?.display(subline: .generic)
        controller.profilebar.display(subline: .generic)
        refresh()
    }
    
    /**
     stops playback and removes all listeners from queue.
     
     - parameters:
        - sharing: _
    */
    func stop(sharing: Void) {
        CliqueAPI.update(listeners: [], for: Identity.me)
        q.manager?.stop()
        q.profilebar?.display(subline: .generic)
        q.fill = nil
        q.shuffled = nil
        refresh()
    }
    
    /**
     shows the tuner.
     
     - parameters:
        - sharing: _
     */
    func view(frequencies: Void) {
        check(frequencies: ())
        
        controller.tunercontroller?.refresh()
        
        let tap = UITapGestureRecognizer(target: controller, action: #selector(controller.escape))
        controller.optionscover.addGestureRecognizer(tap)
        
        controller.tuner.alpha = 0
        controller.optionscover.alpha = 1
        controller.tuner.isHidden = false
        controller.optionscover.isHidden = false
        UIView.animate(withDuration: 0.15) {
            self.controller.tuner.alpha = 1
        }
    }
    
    /**
     sets the voting status.
     
     - parameters:
        - status: if voting is enabled
     */
    func voting(status: Bool) {
        CliqueAPI.update(voting: Identity.me, to: status)
    }
    
}
