//
//  SyncDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class SyncDelegate: BrowseDelegate {
    
    //MARK: - properties
    
    var applemusic: [Playlist] = []
    var spotify: [Playlist]?
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        
        applemusic = Media.getAllPlaylists()
    }
    
    override func title() {
        manager.controller.title = "sync"
        
        manager.controller.table.tableHeaderView = nil
        
        manager.controller.addButton.isEnabled = false
        manager.controller.editButton.isEnabled = false
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, didSelectRowAt: indexPath) }
        
        switch indexPath.section {
        case 0 where !applemusic.isEmpty: manager.sync(new: applemusic[indexPath.row])
        case 1: manager.sync(new: spotify![indexPath.row])
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searching { return nil }
        
        let view = UITableViewHeaderFooterView()
        TableHeaderStyleGuide.enforce(on: view)
        
        return view
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searching { return super.numberOfSections(in: tableView) }
        
        return spotify == nil ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return applemusic.isEmpty ? 1 : applemusic.count
        case 1: return spotify!.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searching { return super.tableView(tableView, cellForRowAt: indexPath) }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlist") ?? UITableViewCell()
        
        switch indexPath.section {
        case 0: cell.textLabel?.text = applemusic.isEmpty ? "no playlists found" : applemusic[indexPath.row].name
        case 1: cell.textLabel?.text = spotify!.isEmpty ? "no playlists found" : spotify![indexPath.row].name
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching { return super.tableView(tableView, titleForHeaderInSection: section) }
        
        switch section {
        case 0: return "Apple Music"
        case 1: return "Spotify"
        default: return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searching { return super.tableView(tableView, canEditRowAt: indexPath) }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, commit: editingStyle, forRowAt: indexPath) }
    }
}
