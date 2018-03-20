//
//  QueueDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class QueueDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {

    //MARK: - properties
    
    var manager: QueueManager

    var me: Bool = false
    var queue: Queue = Queue()
    var fill: Playlist?
    
    //MARK: - initializers
    
    init(to manager: QueueManager) {
        self.manager = manager
        fill = manager.controller.fill
        super.init()
        
        populate()
        title()
    }
    
    //MARK: - actions
    
    func populate() {
        let client = manager.client()
        
        queue = client.queue
        me = client.me()
        
        //if !me { fill = nil }
    }
    
    func title() {
        manager.controller.addbutton.isEnabled = manager.client().me()
        manager.controller.historybutton.isEnabled = manager.client().me()
    }

    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 150
        default: return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break //TODO: swipe to now playing vc
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch indexPath.section {
        case 1 where !queue.queue.isEmpty:
            
            let up = UITableViewRowAction(style: .default, title: "+") { [unowned self] (action, indexpath) in
                let song = self.queue.queue[indexPath.row]
                self.manager.vote(song: song, .up)
                
                if let cell = tableView.cellForRow(at: indexpath) as? QueueSongTableViewCell {
                    guard let votes = cell.voteslabel.text else { return }
                    guard let old = Int(votes) else { return }
                    let new = old + 1
                    cell.voteslabel.text = new.description
                }
            }
            
            let down = UITableViewRowAction(style: .default, title: "-") { [unowned self] (action, indexpath) in
                let song = self.queue.queue[indexPath.row]
                self.manager.vote(song: song, .down)
                
                if let cell = tableView.cellForRow(at: indexpath) as? QueueSongTableViewCell {
                    guard let votes = cell.voteslabel.text else { return }
                    guard let old = Int(votes) else { return }
                    let new = old - 1
                    cell.voteslabel.text = new.description
                }
            }
            
            up.backgroundColor = UIColor.orange
            down.backgroundColor = UIColor.lightGray
            
            if tableView.cellForRow(at: indexPath)?.editingStyle == .delete {
                let delete = UITableViewRowAction(style: .default, title: "Delete") { [unowned self] (_,_) in
                    self.tableView(tableView, commit: .delete, forRowAt: indexPath)
                }
                
                delete.backgroundColor = UIColor.red
                return [up, down, delete]
            }
            
            return [up, down]
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        TableHeaderStyleGuide.enforce(on: view)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        switch indexPath.section {
        case 1 where me: return .delete
        case 2: return .insert
        default: return .none
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        switch sourceIndexPath.section {
        case 1:
            
            switch proposedDestinationIndexPath.section {
            case 0: return IndexPath(row: 0, section: 1)
            case 2: return IndexPath(row: queue.queue.count - 1, section: 1)
            default: return proposedDestinationIndexPath
            }
            
        case 2:
            
            switch proposedDestinationIndexPath.section {
            case 0, 1: return IndexPath(row: 0, section: 2)
            default: return proposedDestinationIndexPath
            }
        
        default: return sourceIndexPath
        }
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return me && fill != nil ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return queue.queue.isEmpty ? 1 : queue.queue.count
        case 2: return fill!.songs.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return NowPlayingTableViewCell(song: queue.current)
        case 1 where queue.queue.isEmpty:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "no songs"
            cell.detailTextLabel?.text = "tap + to add a song to the queue"
            cell.accessoryType = .none
            return cell
        case 1:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: queue.queue[indexPath.row])
            return cell
        case 2:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: fill!.songs[indexPath.row])
            cell.voteslabel.text = nil
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Now Playing"
        case 1: return "Up Next"
        case 2:
            if let owner = CliqueAPI.find(user: fill!.owner), owner.id != Identity.me {
                return "from " + fill!.name + " by @" + owner.username
            } else {
                return "from " + fill!.name
            }
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 1: return queue.queue.isEmpty ? false : me
        case 2: return true
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            
            switch editingStyle {
            case .delete:
                queue.queue.remove(at: indexPath.row)
                if !queue.queue.isEmpty { tableView.deleteRows(at: [indexPath], with: .automatic) }
                manager.update(with: queue)
            case .insert: break
            case .none: break
            }
            
        case 2:
            
            switch editingStyle {
            case .insert:
                let added = fill!.songs[indexPath.row]
                manager.add(song: added)
                fill!.songs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                queue.queue.append(added)
                if !queue.queue.isEmpty { tableView.insertRows(at: [IndexPath(row: queue.queue.count - 1, section: 1)], with: .automatic) }
            case .delete: break
            case .none: break
            }
            
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 1: return queue.queue.isEmpty ? false : me
        case 2: return true
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch sourceIndexPath.section {
        case 1:
            let mover = queue.queue[sourceIndexPath.row]
            queue.queue.remove(at: sourceIndexPath.row)
            queue.queue.insert(mover, at: destinationIndexPath.row)
            manager.update(with: queue)
        case 2:
            let mover = fill!.songs[sourceIndexPath.row]
            fill!.songs.remove(at: sourceIndexPath.row)
            fill!.songs.insert(mover, at: destinationIndexPath.row)
        default: break
        }
    }
    
}
