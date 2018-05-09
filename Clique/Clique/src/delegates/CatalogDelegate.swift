//
//  CatalogDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/13/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class CatalogDelegate: BrowseDelegate {
    
    //MARK: - properties
    
    var item: CatalogItem { return manager.controller.catalog }
    
    var songs = [Song]()
    var albums = [Album]()
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        
        songs.removeAll()
        albums.removeAll()
        
        switch item {
        case let artist as Artist:
            switch artist.library {
            case Catalogues.AppleMusic.rawValue: albums = iTunesAPI.get(albums: artist)
            case Catalogues.Spotify.rawValue: albums = SpotifyAPI.get(albums: artist)
            default: break
            }
        case let album as Album:
            switch album.library {
            case Catalogues.AppleMusic.rawValue: songs = iTunesAPI.get(songs: album)
            case Catalogues.Spotify.rawValue: songs = SpotifyAPI.get(songs: album)
            default: break
            }
        default: break
        }
    }
    
    override func title() {
        switch item {
        case let artist as Artist: manager.controller.title = artist.name
        case let album as Album: manager.controller.title = album.name
        default: break
        }
        
        manager.controller.addButton.isEnabled = false
        manager.controller.editButton.isEnabled = false
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, didSelectRowAt: indexPath) }
        
        switch item {
        case let artist as Artist where indexPath.section == 0:
            var songs = [Song]()
            
            switch artist.library {
            case Catalogues.AppleMusic.rawValue: songs = iTunesAPI.get(songs: artist)
            case Catalogues.Spotify.rawValue: songs = SpotifyAPI.get(top: artist)
            default: break
            }
            
            let playlist = Playlist(
                owner: "",
                id: "",
                library: artist.library,
                name: artist.name,
                social: false,
                songs: songs
            )
            manager.view(playlist: playlist)
        case is Artist: manager.view(catalog: albums[indexPath.row])
        case is Album where final: manager.find(songs: [songs[indexPath.row]])
        case is Album where adding: self.tableView(tableView, commit: .insert, forRowAt: indexPath)
        case let album as Album:
            let playlist = Playlist(
                owner: "",
                id: "",
                library: album.library,
                name: album.name,
                social: false,
                songs: songs
            )
            manager.play(playlist: playlist, at: indexPath.row)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if searching { return super.tableView(tableView, editingStyleForRowAt: indexPath) }
        
        switch item {
        case is Artist: return .none
        case is Album: return adding ? .insert : .none
        default: return .none
        }
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searching { return super.numberOfSections(in: tableView) }
        
        switch item {
        case is Artist: return 2
        case is Album: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching { return super.tableView(tableView, numberOfRowsInSection: section) }
        
        switch item {
        case is Artist where section == 0: return 1
        case is Artist: return albums.count
        case is Album: return songs.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
        if searching { return super.tableView(tableView, cellForRowAt: indexPath) }
        
        switch item {
        case is Artist where indexPath.section == 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "top songs"
            cell.accessoryType = .disclosureIndicator
            return cell
        case is Artist:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = albums[indexPath.row].name
            cell.detailTextLabel?.text = albums[indexPath.row].year
            cell.accessoryType = .disclosureIndicator
            let url = URL(string: albums[indexPath.row].artwork) ?? URL(string: "/")!
            cell.imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "songpic.png"))
            cell.setImageSize(to: 45)
            return cell
        case is Album:
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: songs[indexPath.row])
            cell.voteslabel.text = nil
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searching { return super.tableView(tableView, canEditRowAt: indexPath) }
        
        switch item {
        case is Artist: return false
        case is Album: return true
        default: return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, commit: editingStyle, forRowAt: indexPath) }
        
        switch editingStyle {
        case .insert: q.manager?.find(song: songs[indexPath.row], from: manager.controller, confirmed: q.manager?.client().me() ?? false)
        case .none, .delete: break
        }
    }
    
}
