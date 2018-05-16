//
//  RadioDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class RadioDelegate: RequestsDelegate {
    
    //MARK: - properties
    
    var singles = [Single]()
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        singles = q.radio
    }
    
    override func title() {
        manager.controller.navigationItem.title = "wave radio"
        
        manager.controller.addbutton.isEnabled = false
        manager.controller.historybutton.isEnabled = false
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Actions.view(single: indexPath.row, on: controller)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - table data source stack
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singles.isEmpty ? 1 : singles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch singles.isEmpty {
        case true:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "finding songs..."
            cell.detailTextLabel?.text = "loading content from wave radio"
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
            return cell
        case false:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(single: singles[indexPath.row])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            let added = singles[indexPath.row]
            singles.remove(at: indexPath.row)
            q.radio = singles
            if !singles.isEmpty { tableView.deleteRows(at: [indexPath], with: .automatic) }
            else { tableView.reloadData() }
            
            manager.add(single: added)
        case .delete, .none: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
