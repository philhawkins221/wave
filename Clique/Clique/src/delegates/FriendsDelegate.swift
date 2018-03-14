//
//  FriendsDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 1/17/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class FriendsDelegate: BrowseDelegate {
    
    //MARK: - properties
    
    var friends = Identity.friends
    
    //MARK: - actions
    
    override func title() {
        manager.controller.title = "Browse"
    }
    
    //MARK : - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, didSelectRowAt: indexPath) }
        
        switch indexPath.section {
        case 0: manager.view(user: Identity.me)
        case 1: manager.view(user: friends[indexPath.row])
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if searching { return super.tableView(tableView, editingStyleForRowAt: indexPath) }
        
        return .none
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searching { return super.numberOfSections(in: tableView) }
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching { return super.tableView(tableView, numberOfRowsInSection: section) }
        
        switch friends.isEmpty {
        case true: return 1
        case false: return section == 0 ? 1 : friends.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
        if searching { return super.tableView(tableView, cellForRowAt: indexPath) }
        var cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "My Library"
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: "clique 120.png")
            cell.setImageSize(to: 50)
            cell.imageView?.layer.cornerRadius = cell.frame.size.width / 2
            cell.imageView?.clipsToBounds = true
        case 1 where friends.isEmpty:
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "no friends"
            cell.detailTextLabel?.text = "tap + to add a friend"
        case 1:
            if let friend = CliqueAPI.find(user: friends[indexPath.row]) {
                cell.textLabel?.text = "@" + friend.username
                cell.accessoryType = .disclosureIndicator
                cell.imageView?.image = UIImage(named: "clique 120.png")
                cell.setImageSize(to: 50)
                cell.imageView?.layer.cornerRadius = cell.frame.size.width / 2
                cell.imageView?.clipsToBounds = true
            } else {
                cell.textLabel?.text = "deleted user"
                cell.textLabel?.textColor = UIColor.gray
                cell.accessoryType = .none
            }
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searching { return super.tableView(tableView, canEditRowAt: indexPath) }
        
        return indexPath.section != 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, commit: editingStyle, forRowAt: indexPath) }
        
        switch editingStyle {
        case .delete:
            friends.remove(at: indexPath.row)
            //TODO: gm.unfriend(friends[indexPath.row])
        case .insert: break
        case .none: break
        }
    }
}
