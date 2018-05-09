//
//  Media.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

class Media: NSObject {
    
    static var clone = Media()
    static var playing = false
    static var paused = false
    
    private static var advanced = false
    private static var checks = -2
    private static var searcher = UIViewController()
    private static var silence = AVQueuePlayer()
    private static var token: Any?
    
    private static var context = 0
    
    static func authenticate() -> Bool {
        switch SKCloudServiceController.authorizationStatus() {
        case .authorized: return true
        case .denied: return false //TODO: inform access denied
        case .notDetermined: break
        case .restricted: return false
        }
        
        SKCloudServiceController.requestAuthorization { (status: SKCloudServiceAuthorizationStatus) in
            switch status {
            case .authorized: gm?.connect(applemusic: true)
            case .denied, .notDetermined, .restricted: break
            }
        }
            
        return false
    }
    
    static func background(at time: CMTime) {
        print("media background song checking")
        checks += 1
        
        if checks >= 10 {
            Media.silence.seek(to: kCMTimeZero)
            print("background seeking back")
            Media.checks = 0
        } else if checks < 0 {
            return
        }
        
        print("background: player status:", player.playbackState.rawValue)
        if playing, player.playbackState == .playing, advanced {
            advanced = false //open the gate
        } else if playing, !paused, player.playbackState == .paused, player.currentPlaybackTime == 0, !advanced {
            print("background advancing")
            advanced = true //close the gate
            q.manager?.advance()
        } else if playing, player.playbackState == .stopped, !advanced {
            print("background advancing")
            advanced = true //close the gate
            q.manager?.advance()
        }
    }
    
    static func play(song: Song? = nil) {
        paused = false
        guard let song = song else { return player.play() }
        
        prepare()
        
        switch song.library {
        case Catalogues.Library.rawValue:
            let predicate = MPMediaPropertyPredicate(value: Int(song.id), forProperty: MPMediaItemPropertyPersistentID)
            let searcher = MPMediaQuery.songs()
            searcher.addFilterPredicate(predicate)
            player.setQueue(with: MPMediaItemCollection(items: searcher.items ?? []))
        case Catalogues.AppleMusic.rawValue:
            player.setQueue(with: [song.id])
        default: break
        }
        
        playing = true
        np.waves.isHidden = true
        silence.play()
    }
    
    static func pause() {
        paused = true
        player.pause()
    }
    
    static func prepare() {
        if token != nil { silence.removeTimeObserver(token!) }
        
        let item = AVPlayerItem(url: Bundle.main.url(forResource: "silence", withExtension: "mp3")!)
        item.addObserver(clone, forKeyPath: "status", options: .new, context: &context)
        
        silence.replaceCurrentItem(with: nil)
        silence = AVQueuePlayer(items: [item])
        silence.allowsExternalPlayback = false
        silence.usesExternalPlaybackWhileExternalScreenIsActive = false
        player.repeatMode = .none
        checks = -2
    }
    
    static func search(multiple: Bool, on controller: BrowseViewController) {
        searcher = controller
        
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.delegate = controller.manager?.delegate
        picker.allowsPickingMultipleItems = multiple
        picker.prompt = controller.navigationItem.prompt
        
        controller.present(picker, animated: true)
    }
    
    static func stop() {
        playing = false
        advanced = true
        if token != nil { silence.removeTimeObserver(token as Any) }
        //silence.currentItem?.removeObserver(clone, forKeyPath: "status")
        silence.removeAllItems()
        token = nil
        player.stop()
    }
    
    static func find() {
        searcher.dismiss(animated: true)
    }
    
    static func get(artwork id: String, size: CGSize? = nil) -> UIImage? {
        let size = size ?? CGSize(width: 45, height: 45)
        let searcher = MPMediaQuery.songs()
        searcher.addFilterPredicate(MPMediaPropertyPredicate(value: Int(id), forProperty: MPMediaItemPropertyPersistentID))
        return searcher.items?.first?.artwork?.image(at: size)
    }
    
    static func get(song id: String) -> Song? {
        let searcher = MPMediaQuery.songs()
        searcher.addFilterPredicate(MPMediaPropertyPredicate(value: Int(id), forProperty: MPMediaItemPropertyPersistentID))
        
        if let song = searcher.items?.first { return virtualize(song: song) }
        else { return nil }
    }
    
    static func get(playlist id: String) -> Playlist? {
        let playlists = getAllPlaylists().filter { $0.id == id }
        
        if playlists.count == 1, let playlist = playlists.first { return playlist }
        else { return nil }
    }
    
    static func getAllPlaylists() -> [Playlist] {
        var results = [Playlist]()
        
        let searcher = MPMediaQuery.playlists()
        for collection in searcher.collections ?? [] {
            if let playlist = collection as? MPMediaPlaylist {
                results.append(virtualize(playlist: playlist, from: .AppleMusic))
            }
        }
        
        return results
    }
    
    static func virtualize(song: MPMediaItem, from source: Catalogues = .Library) -> Song {
        return Song(
            id: String(song.persistentID),
            library: source.rawValue,
            title: song.title ?? "",
            artist: Artist(
                id: String(song.artistPersistentID),
                library: Catalogues.Library.rawValue,
                name: song.artist ?? ""),
            sender: "",
            artwork: "",
            votes: 0
        )
    }
    
    static func virtualize(playlist: MPMediaPlaylist, from source: Catalogues = .Library) -> Playlist {
        return Playlist(
            owner: Identity.me,
            id: String(playlist.persistentID),
            library: source.rawValue,
            name: playlist.name ?? "",
            social: true,
            songs: playlist.items.map { virtualize(song: $0) }
        )
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &Media.context else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        if keyPath == "status" {
            if Media.silence.currentItem!.status == .failed { print(Media.silence.currentItem?.error as Any) }
            if Media.silence.currentItem!.status == .readyToPlay {
                player.play()
                
                let interval = CMTime(seconds: 3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                Media.token = Media.silence.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: Media.background)
            }
        }
    }

}
