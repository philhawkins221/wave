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
    
    var friends = [User]()
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        
        for friend in manager.client().friends {
            if let found = CliqueAPI.find(user: friend) { friends.append(found) }
        }
    }
    
    override func title() {
        manager.controller.title = "browse"
        
        manager.controller.addButton.isEnabled = manager.client().me()
        manager.controller.editButton.isEnabled = false //manager.client().me()
        manager.controller.editButton.title = ""
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, didSelectRowAt: indexPath) }
        
        switch indexPath.section {
        case 0: manager.view(user: Identity.me)
        case 1 where friends.isEmpty: tableView.deselectRow(at: indexPath, animated: true)
        case 1: Actions.view(user: friends[indexPath.row], on: controller)
        case 1: manager.view(user: friends[indexPath.row].id)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searching { return super.tableView(tableView, viewForHeaderInSection: section) }
        
        let view = UITableViewHeaderFooterView()
        TableHeaderStyleGuide.enforce(on: view)
        return view
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if searching { return super.tableView(tableView, editingStyleForRowAt: indexPath) }
        
        return .delete
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
            cell.textLabel?.text = "@" + manager.client().username
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = #imageLiteral(resourceName: "clique 120.png")
            cell.setImageSize(to: 40)
            cell.imageView?.layer.cornerRadius = cell.imageView!.frame.size.width / 2
            cell.imageView?.clipsToBounds = true
        case 1 where friends.isEmpty:
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "no friends"
            cell.detailTextLabel?.text = "tap + to add a friend"
            cell.selectionStyle = .none
        case 1:
            cell.textLabel?.text = "@" + friends[indexPath.row].username
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = #imageLiteral(resourceName: "clique 120.png")
            cell.setImageSize(to: 40)
            cell.imageView?.layer.cornerRadius = cell.imageView!.frame.size.width / 2
            cell.imageView?.clipsToBounds = true
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching { return super.tableView(tableView, titleForHeaderInSection: section) }
        
        switch section {
        case 0: return "library"
        case 1: return "friends"
        default: return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searching { return super.tableView(tableView, canEditRowAt: indexPath) }
        
        return indexPath.section != 0 && !friends.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if searching { return super.tableView(tableView, commit: editingStyle, forRowAt: indexPath) }
        
        switch editingStyle {
        case .delete:
            manager.delete(friend: friends[indexPath.row], confirmed: false)
            friends.remove(at: indexPath.row)
            if !friends.isEmpty { tableView.deleteRows(at: [indexPath], with: .automatic) }
            manager.refresh()
        case .insert: break
        case .none: break
        }
    }
    
    //MARK: - search delegate stack
    
    func didPresentSearchController(_ searchController: UISearchController) {
        if final { searchController.searchBar.becomeFirstResponder() }
    }
}
