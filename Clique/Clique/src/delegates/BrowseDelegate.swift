//
//  BrowseDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 1/17/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation
import MediaPlayer

class BrowseDelegate: NSObject, UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    //MARK: - properties
    
    var manager: BrowseManager
    
    var searching: Bool { return manager.controller.search.isActive }
    var adding: Bool { return manager.controller.adding }
    var final: Bool { return manager.controller.final }
    
    var all: Playlist {
        return Playlist(
            owner: manager.client().id,
            id: "",
            library: "",
            name: searching ? "search" : "library",
            social: true,
            songs: searching ? results : list
        )
    }
    
    var editing = false
    
    private var songs = [[Song]](repeating: [], count: 27)
    var list = [Song]()
    var results = [Song]()
    var sort = Sorting.artist
    var fields = (users: false, library: false, applemusic: false, spotify: false, count: 0)
    
    //MARK: - initializers
    
    init(to manager: BrowseManager) {
        self.manager = manager
        super.init()
        
        populate()
        title()
    }
    
    //MARK: - actions
    
    func populate() {
        let client = manager.client()
        
        songs = [[Song]](repeating: [], count: 27)
        list = [Song]()
        results = [Song]()
        
        for playlist in client.library {
            let uniques = playlist.songs.filter { !list.contains($0) }
            list.append(contentsOf: uniques)
        }
        
        switch sort {
        case .artist: list.sort { $0.artist.name < $1.artist.name }
        case .song: list.sort { $0.title < $1.title }
        }
        
        for song in list {
            let sortname: String
            
            switch sort {
            case .artist: sortname = song.artist.name.lowercased()
            case .song: sortname = song.title.lowercased()
            }
            
            var index = Int((sortname.first?.unicodeScalars.map { $0.value }.reduce(0, +)) ?? 0) - 97
            if index < 0 || index > 25 { index = 26 }
            
            songs[index].append(song)
        }
        
        for i in 0..<songs.count {
            switch sort {
            case .artist: songs[i].sort { $0.artist.name < $1.artist.name }
            case .song: songs[i].sort { $0.title < $1.title }
            }
        }
        
        fields.users = true
        fields.library = true //client.me()
        fields.applemusic = client.applemusic
        fields.spotify = client.spotify
        
        var count = 0
        if fields.users { count += 1 }
        if fields.library { count += 1 }
        if fields.applemusic { count += 1 }
        if fields.spotify { count += 1 }
        
        fields.count = count
    }
    
    func title() {
        manager.controller.title = "all songs"
        
        manager.controller.addButton.isEnabled = false
        manager.controller.editButton.isEnabled = false
    }
    
    //MARK: -  table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch searching {
        case true where indexPath.section == 0: return 40
        default: return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let allsongs = Playlist(
            owner: manager.client().id,
            id: "",
            library: "",
            name: searching ? "search" : "library",
            social: true,
            songs: searching ? results : list
        )
        
        switch searching {
        case true where indexPath.section == 0:
            manager.view(
                search: manager.controller.search.searchBar.text ?? "",
                from: tableView.cellForRow(at: indexPath)?.textLabel?.text ?? ""
            )
        case _ where adding: self.tableView(tableView, commit: .insert, forRowAt: indexPath)
        case true where final: manager.find(songs: [results[indexPath.row]])
        case true: manager.play(playlist: allsongs, at: indexPath.row)
        case false where final: manager.find(songs: [songs[indexPath.section][indexPath.row]])
        case false: manager.play(playlist: allsongs, at: list.index(of: songs[indexPath.section][indexPath.row]) ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch searching {
        case true: return nil
        case false:
            let view = UITableViewHeaderFooterView()
            TableHeaderStyleGuide.enforce(on: view)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if adding { return .insert }
        return .none
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return sourceIndexPath
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch searching {
        case true: return 2
        case false: return songs.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searching {
        case true where section == 0:
            switch manager.controller.search.searchBar.text {
                case .some: return manager.controller.search.searchBar.text == "" ? 1 : fields.count
                case nil: return fields.library ? 1 : 0
            }
        case true: return results.count
        case false: return songs[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
        
        switch searching {
        case true where indexPath.section == 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            switch manager.controller.search.searchBar.text {
            case .some(let query):
                var prompts = [String]()
                
                if fields.users && query != "" { prompts.append("search username @" + query + "...") }
                if fields.library { prompts.append("search Device Library...") }
                if fields.applemusic && query != "" { prompts.append("search Apple Music for '" + query + "'...") }
                if fields.spotify && query != "" { prompts.append("search Spotify for '" + query + "'...")}
                
                cell.textLabel?.text = prompts[indexPath.row]
                cell.textLabel?.textColor = UIColor.orange
                
            case nil where fields.library: cell.textLabel?.text = "Search Device Library..."
            default: break
            }
            
            return cell
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: results[indexPath.row])
            cell.voteslabel.text = nil
            return cell
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: songs[indexPath.section][indexPath.row])
            cell.voteslabel.text = nil
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching { return nil }
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "123"][section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searching { return nil }
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "123"]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch searching {
        case true where indexPath.section == 0: return false
        case true: return true
        case false: return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            
            switch searching {
            case true: q.manager?.find(song: results[indexPath.row], from: manager.controller, confirmed: q.manager?.client().me() ?? false)
            case false: q.manager?.find(song: songs[indexPath.section][indexPath.row], from: manager.controller, confirmed: q.manager?.client().me() ?? false)
            }
            
        case .delete: break
        case .none: break
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
    
    //MARK: - search delegate stack
    
    func willPresentSearchController(_ searchController: UISearchController) {
        if manager.controller.table.isEditing { editing = true }
        if editing && !adding { manager.controller.table.setEditing(false, animated: true) }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        if editing { manager.controller.table.setEditing(true, animated: true) }
        editing = false
        searchController.searchBar.resignFirstResponder()
    }
    
    //MARK: - search results updater stack
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = manager.controller.search.searchBar.text?.lowercased() else { return }
        results.removeAll()
        
        for letter in songs {
            results.append(contentsOf: letter.filter {
                $0.artist.name.lowercased().contains(query) || $0.title.lowercased().contains(query)
            })
        }
        
        manager.controller.table.reloadData()
    }
    
    //MARK: - media picker delegate stack
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        var songs = [Song]()
        for song in mediaItemCollection.items { songs.append(Media.virtualize(song: song)) }
        
        if adding && !songs.isEmpty { return q.manager?.find(song: songs.first!, from: manager.controller, confirmed: q.manager?.client().me() ?? false) ?? () }
        if final { return manager.find(songs: songs) }
        
        let selected = Playlist(
            owner: manager.client().id,
            id: "",
            library: "",
            name: "Search",
            social: true,
            songs: songs
        )
        
        manager.play(playlist: selected, at: 0)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
}
