//
//  RequestsDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class RequestsDelegate: QueueDelegate {
    
    //MARK: - properties
    
    var songs = [Song]()
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        songs = queue.requests
    }
    
    override func title() {
        manager.controller.navigationItem.title = "requests"
        
        manager.controller.addbutton.isEnabled = false
        manager.controller.historybutton.isEnabled = false
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !songs.isEmpty && indexPath.row == songs.count {
            return manager.delete(requests: ())
        }
        
        Actions.view(song: queue.requests[indexPath.row], on: controller)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .insert
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        var approvedDestinationIndexPath = proposedDestinationIndexPath
        
        if proposedDestinationIndexPath.row >= songs.count {
            approvedDestinationIndexPath.row = songs.count - 1
        }
        
        return approvedDestinationIndexPath
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.isEmpty ? 1 : me ? songs.count + 1 : songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch songs.isEmpty {
        case true:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "no requests"
            cell.detailTextLabel?.text = "new requests will appear here"
            return cell
        case false where indexPath.row == songs.count:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "remove all"
            cell.textLabel?.textColor = UIColor.orange
            return cell
        case false:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: songs[indexPath.row], voting: true, credit: true)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return me && !songs.isEmpty && indexPath.row != songs.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            let added = songs[indexPath.row]
            songs.remove(at: indexPath.row)
            manager.update(requests: songs, refresh: false)
            manager.add(song: added)
            if !songs.isEmpty { tableView.deleteRows(at: [indexPath], with: .automatic) }
            else { tableView.reloadData() }
        case .delete, .none: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return me && !songs.isEmpty && indexPath.row != songs.count
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = songs[sourceIndexPath.row]
        songs.remove(at: sourceIndexPath.row)
        songs.insert(mover, at: destinationIndexPath.row)
        manager.update(requests: songs, refresh: false)
    }
    
}
