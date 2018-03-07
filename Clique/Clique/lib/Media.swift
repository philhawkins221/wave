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
    }
    
    static func picker(with delegate: BrowseDelegate) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.delegate = delegate
        
        picker.allowsPickingMultipleItems = true
        picker.prompt = "Select songs to be added to the playlist"
        
        return picker
    }
    
    static func get(song: MPMediaItem) -> Song {
        return Song(
            id: String(song.persistentID),
            library: Catalogues.Library.rawValue,
            title: song.title ?? "",
            artist: Artist(
                id: String(song.artistPersistentID),
                library: Catalogues.Library.rawValue,
                name: song.artist ?? ""),
            artwork: "",
            votes: 0)
    }
    
    static func get(playlist: MPMediaPlaylist, from source: Catalogues = .Library) -> Playlist {
        return Playlist(
            owner: Identity.sharedInstance().me,
            id: String(playlist.persistentID),
            library: source.rawValue,
            name: playlist.name ?? "",
            social: false,
            songs: playlist.items.map { get(song: $0) })
    }
    
    static func getAllPlaylists() -> [Playlist] {
        var results = [Playlist]()
        
        let searcher = MPMediaQuery.playlists()
        for playlist in searcher.collections ?? [] {
            if let result = playlist as? MPMediaPlaylist {
                results.append(get(playlist: result, from: .AppleMusic))
            }
        }
        
        return results
    }
    
    static func find(song id: String) -> Song? {
        return nil
    }
    
    static func get(artwork id: String) -> UIImage? {
        let searcher = MPMediaQuery.songs()
        searcher.addFilterPredicate(MPMediaPropertyPredicate(value: Int(id), forProperty: MPMediaItemPropertyPersistentID))
        return searcher.items?.first?.artwork?.image(at: CGSize(width: 45, height: 45))
    }
    
}
