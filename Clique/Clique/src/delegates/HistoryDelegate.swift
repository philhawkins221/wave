//
//  HistoryDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/14/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class HistoryDelegate: QueueDelegate {
    
    //MARK: - properties
    
    var history = [Song]()
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        history = manager.client().queue.history
        //history.reverse()
    }
    
    override func title() {
        manager.controller.title = "history"
        
        manager.controller.addbutton.isEnabled = false
        manager.controller.historybutton.isEnabled = false
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Actions.view(song: history[indexPath.row], on: controller)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
        cell.set(song: queue.history[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
