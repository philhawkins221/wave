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
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        listeners.removeAll()
        
        for listener in queue.listeners {
            if let found = CliqueAPI.find(user: listener) {
                listeners.append(found)
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
        switch indexPath.row {
        case _ where indexPath.row == listeners.count && !listeners.isEmpty: break //TODO: add user
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return indexPath.row == listeners.count ? .none : .delete
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listeners.isEmpty ? 2 : listeners.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if listeners.isEmpty && indexPath.row == 0 {
            cell.textLabel?.text = "no listeners"
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .none
            return cell
        } else if listeners.isEmpty || indexPath.row == listeners.count {
            cell.textLabel?.text = "invite friends"
            cell.textLabel?.textColor = UIColor.orange
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            cell.textLabel?.text = "@" + listeners[indexPath.row].username
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != listeners.count && !listeners.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        listeners.remove(at: indexPath.row)
        manager.update(listeners: listeners.map { $0.id })
        if listeners.isEmpty { tableView.reloadData() }
        else { tableView.reloadRows(at: [indexPath], with: .automatic) }
        
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
