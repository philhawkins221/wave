//
//  PlaylistDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 1/17/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class PlaylistDelegate: BrowseDelegate {
    
    //MARK: - properties
    
    var playlist: Playlist
    
    //MARK: - initializers
    
    override init(to manager: BrowseManager) {
        self.playlist = manager.controller.playlist
        super.init(to: manager)
    }
    
    //MARK: - actions
    
    override func title() {
        manager.controller.title = playlist.name
        
        manager.controller.addButton.isEnabled = manager.client().me() && playlist.library == Catalogues.Library.rawValue
        manager.controller.editButton.isEnabled = manager.client().me()
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, didSelectRowAt: indexPath) }
        if adding { return self.tableView(tableView, commit: .insert, forRowAt: indexPath) }
        if final { manager.find(songs: [playlist.songs[indexPath.row]]) }
        
        manager.play(playlist: playlist, at: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if searching { return super.tableView(tableView, editingStyleForRowAt: indexPath) }
        if adding { return playlist.songs.isEmpty ? .none : .insert }
        
        return playlist.songs.isEmpty ? .none : .delete
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searching { return super.numberOfSections(in: tableView) }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching { return super.tableView(tableView, numberOfRowsInSection: section) }
        
        return playlist.songs.isEmpty ? 1 : playlist.songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
        
        if searching { return super.tableView(tableView, cellForRowAt: indexPath) }
        
        switch playlist.songs.isEmpty {
        case true:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "no songs"
            cell.detailTextLabel?.text = "tap + to add a song"
            return cell
        case false:
        let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
        cell.set(song: playlist.songs[indexPath.row])
        cell.voteslabel.text = nil
        return cell
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
        
        return !playlist.songs.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, commit: editingStyle, forRowAt: indexPath) }
        
        switch editingStyle {
        case .insert: q.manager?.find(song: playlist.songs[indexPath.row])
        case .delete:
            playlist.songs.remove(at: indexPath.row)
            manager.controller.playlist = playlist
            var replacement: [Playlist]? = manager.client().library
            if let i = replacement?.index(of: playlist) { replacement![i] = playlist }
            else { replacement = nil }
            
            manager.update(with: replacement)
        case .none: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if searching { return super.tableView(tableView, canMoveRowAt: indexPath) }
        
        return !playlist.songs.isEmpty && playlist.owner == manager.client().id
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if searching
            { return super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath) }
        
        let mover = playlist.songs[sourceIndexPath.row]
        playlist.songs.remove(at: sourceIndexPath.row)
        playlist.songs.insert(mover, at: destinationIndexPath.row)
        
        var replacement: [Playlist]! = manager.client().library
        
        if let i = replacement.index(of: playlist) { replacement[i] = playlist }
        else { replacement = nil }
        
        manager.update(with: replacement)
    }
    
}
