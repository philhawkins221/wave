//
//  Media.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation
import MediaPlayer

struct Media {
    
    static var searcher = UIViewController()
    
    static func play(song: Song? = nil) {
        
        
        //TODO: where to end generating notifications?
        player.endGeneratingPlaybackNotifications()
        
        //if nil then press play
        guard let song = song else {
            //TODO: needs work
            player.play()
            return
        }
        //case library
        //add song to queue twice
        //enable nowplayingdidchange notifications
        
        switch song.library {
        case Catalogues.Library.rawValue:
            //TODO: double method may not work
            let predicate = MPMediaPropertyPredicate(value: Int(song.id), forProperty: MPMediaItemPropertyPersistentID)
            let searcher = MPMediaQuery.songs()
            let double = MPMediaQuery.songs()
            searcher.addFilterPredicate(predicate)
            double.addFilterPredicate(predicate)
            let collection = MPMediaItemCollection(items: (searcher.items ?? []) + (double.items ?? []))
            player.setQueue(with: collection)
            player.play()
            player.beginGeneratingPlaybackNotifications()
        case Catalogues.AppleMusic.rawValue: break
        case Catalogues.Spotify.rawValue: break
        default: break
        }
    }
    
    static func pause() {
        //TODO: pause
        player.pause()
    }
    
    static func search(multiple: Bool, on controller: BrowseViewController) {
        searcher = controller
        
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.delegate = controller.manager?.delegate
        picker.allowsPickingMultipleItems = multiple
        picker.prompt = controller.navigationItem.prompt
        
        controller.present(picker, animated: true)
    }
    
    static func find() {
        searcher.dismiss(animated: true)
    }
    
    static func get(artwork id: String) -> UIImage? {
        let searcher = MPMediaQuery.songs()
        searcher.addFilterPredicate(MPMediaPropertyPredicate(value: Int(id), forProperty: MPMediaItemPropertyPersistentID))
        return searcher.items?.first?.artwork?.image(at: CGSize(width: 45, height: 45))
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

}
