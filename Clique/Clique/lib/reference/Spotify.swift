//
//  Spotify.swift
//  Clique
//
//  Created by Phil Hawkins on 3/29/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation
import SafariServices
import MediaPlayer

class Spotify: NSObject, SPTAuthViewDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    static var authorization = ""
    static var playing = false
    static var controller: SettingsViewController?
    static var player = SPTAudioStreamingController(clientId: kClientId)
    
    private static var advanced = false
    private static var checks = 0
    private static var silence = AVQueuePlayer()
    private static var token: Any?
    private static var context = 1000
    
    
    static var clone = Spotify()
    
    static func authenticate() -> Bool {
        if (spotifyauth?.session == nil) { //no session
            spotifyauth?.clientID = kClientId
            spotifyauth?.redirectURL = URL(string: kCallbackURL)
            spotifyauth?.sessionUserDefaultsKey = "session"
            spotifyauth?.requestedScopes = [SPTAuthStreamingScope]
            
            player?.delegate = clone
            
            //guard let vc = SPTAuthViewController.authentication() else { return false }
            guard let url = SPTAuth.loginURL(forClientId: kClientId, withRedirectURL: URL(string: kCallbackURL), scopes: [SPTAuthStreamingScope], responseType: "token")
            else { return false }
            let vc = SFSafariViewController(url: url)
            controller?.present(vc, animated: true)
            return false
        } else if (spotifyauth?.session.isValid() ?? false) { //session valid
            print("Spotify: session is valid")
            authorization = spotifyauth!.session.accessToken!
            player?.delegate = clone
            player?.login(with: spotifyauth!.session) { _ in }
            return true
        } else { //TODO: session expired
            /*SPTAuth.defaultInstance().renewSession(spotifysession, callback: {(error, session) in
                if error == nil {
                    spotifysession = session
                    gm?.connect(spotify: true)
                }
            })*/
            spotifyauth?.session = nil
            Settings.spotify = false
            return false
        }
    }
    
    static func background(at time: CMTime) {
        print("spotify background song checking")
        Spotify.checks += 1
        
        if checks >= 10 {
            silence.seek(to: kCMTimeZero)
            print("background seeking back")
            checks = 0
        }
        
        print("background: player status:", player?.isPlaying)
        /*
        if playing, player?.isPlaying ?? false, advanced {
            advanced = false //open the gate
        } else if playing, player?.isPlaying ?? false, !advanced {
            print("background advancing")
            advanced = true //close the gate
            q.manager?.advance()
        } else if Media.playing, player?.isPlaying ?? false, !advanced {
            advanced = true //close the gate
            print("background advancing")
            q.manager?.advance()
        }*/
    }
    
    static func pause() {
        playing = false
        player?.setIsPlaying(false) { _ in }
    }
    
    static func play(song: Song? = nil) {
        guard let song = song else {
            playing = true
            player?.setIsPlaying(true) { _ in }
            return
        }
        
        prepare()

        player?.delegate = clone
        player?.playURIs([URL(string: song.id) as Any], from: 0) { _ in }
        playing = true
        //silence.play()
    }
    
    static func prepare() {
        if token != nil { silence.removeTimeObserver(token!) }
        
        let item = AVPlayerItem(url: Bundle.main.url(forResource: "silence", withExtension: "mp3")!)
        item.addObserver(clone, forKeyPath: "status", options: .new, context: &context)
        
        silence.replaceCurrentItem(with: nil)
        silence = AVQueuePlayer(items: [item])
        //silence.allowsExternalPlayback = false
        silence.usesExternalPlaybackWhileExternalScreenIsActive = false
        player?.repeat = false
    }
    
    static func stop() {
        playing = false
        if token != nil { silence.removeTimeObserver(token as Any) }
        //silence.currentItem?.removeObserver(clone, forKeyPath: "status")
        silence.pause()
        token = nil
        player?.delegate = nil
        player?.setIsPlaying(false) { _ in }
        player?.queueURIs([], clearQueue: true) { _ in }
    }
    
    //MARK: - spotify authentication delegate stack
    
    func authenticationViewController(_ authenticationViewController: SPTAuthViewController!, didLoginWith session: SPTSession!) {
        spotifysession = session
        print("succeeded spotify authentication with session")
        gm?.connect(spotify: true)
        
        authenticationViewController.dismiss(animated: true)
    }
    
    func authenticationViewControllerDidCancelLogin(_ authenticationViewController: SPTAuthViewController!) {
        gm?.connect(spotify: false)
    }
    
    func authenticationViewController(_ authenticationViewController: SPTAuthViewController!, didFailToLogin error: Error!) {
        gm?.connect(spotify: false)
        authenticationViewController.dismiss(animated: true)
    }
    
    //MARK: - spotify audio streaming delegate stack
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {}
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: URL!) {
        if Spotify.playing { q.manager?.advance() }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if Spotify.playing { q.manager?.advance() }
    }
    
    //MARK: - clone stack
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &Spotify.context else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        if keyPath == "status" {
            if Spotify.silence.currentItem!.status == .failed { print(Spotify.silence.currentItem?.error as Any) }
            if Spotify.silence.currentItem!.status == .readyToPlay {
                Spotify.player?.setIsPlaying(true) { _ in }
                
                let interval = CMTime(seconds: 3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                Spotify.token = Spotify.silence.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: Spotify.background)
            }
        }
    }
    
}
