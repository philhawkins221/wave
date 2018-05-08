//
//  ListenersDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/27/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class ListenersDelegate: QueueDelegate {
    
    var listeners = [User]()
    var friends = [User]()
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        listeners.removeAll()
        friends.removeAll()
        
        let client = manager.client()
        for friend in client.friends {
            if queue.listeners.contains(friend) { continue }
            if let friend = CliqueAPI.find(user: friend) { friends.append(friend) }
        }
        
        for listener in queue.listeners {
            if let listener = CliqueAPI.find(user: listener) {
                listeners.append(listener)
            }
        }
    }
    
    override func title() {
        manager.controller.title = "listeners"
        
        manager.controller.addbutton.isEnabled = false
        manager.controller.historybutton.isEnabled = false
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let style = tableView.cellForRow(at: indexPath)?.editingStyle ?? .none
        
        return style == .none ?
        tableView.deselectRow(at: indexPath, animated: true) :
        self.tableView(tableView, commit: style, forRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "kick"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        TableHeaderStyleGuide.enforce(on: view)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1 where friends.isEmpty: return 0
        default: return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        switch indexPath.section {
        case 0 where !listeners.isEmpty: return .delete
        case 1: return .insert
        default: return .none
        }
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return listeners.isEmpty ? 1 : listeners.count
        case 1: return friends.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 where listeners.isEmpty && friends.isEmpty:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "no listeners"
            cell.detailTextLabel?.text = "add friends to share the queue"
            return cell
        case 0 where listeners.isEmpty:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "no listeners"
            return cell
        case 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "@" + listeners[indexPath.row].username
            return cell
        case 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "@" + friends[indexPath.row].username
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "friends listening:"
        case 1: return "invite friends to the queue"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            q.manager?.invite(friend: friends[indexPath.row])
        case .delete:
            listeners.remove(at: indexPath.row)
            manager.update(listeners: listeners.map { $0.id })
            if listeners.isEmpty { tableView.reloadData() }
            else { tableView.reloadRows(at: [indexPath], with: .automatic) }
        case .none: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
