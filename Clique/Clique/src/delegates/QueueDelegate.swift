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
    var queue = Queue()
    var fill = Playlist()
    var radio = Playlist()
    
    var queuerows = 5
    var requestrows = 3
    var radiorows = 3
    
    //MARK: - initializers
    
    init(to manager: QueueManager) {
        self.manager = manager
        fill = manager.controller.fill ?? Playlist()
        super.init()
        
        populate()
        title()
    }
    
    //MARK: - actions
    
    func populate() {
        let client = manager.client()
        
        queue = client.queue
        me = client.me()
        
        if !me { queuerows = -1 }
        if queue.queue.isEmpty { queuerows = 1 }
    }
    
    func title() {
        manager.controller.addbutton.isEnabled = manager.client().me()
        manager.controller.historybutton.isEnabled = manager.client().me()
    }

    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 150
        case 1 where indexPath.row == queuerows,
             2 where indexPath.row == requestrows,
             3 where indexPath.row == radiorows: return 30
        default: return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: break //TODO: swipe to now playing vc
        case 1 where indexPath.row == queuerows:
            queuerows += 5
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        case 2 where indexPath.row == requestrows: break //TODO: manager.view(requests: ())
        case 3 where indexPath.row == radiorows: break //TODO: manager.view(radio: ())
        case 2, 3, 4: break //TODO: manager.play
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch indexPath.section {
        case 1 where !queue.queue.isEmpty && indexPath.row != queuerows:
            
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case 2 where queue.requests.isEmpty,
                 3 where radio.songs.isEmpty,
                 4 where fill.songs.isEmpty: return 0
        default: return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        TableHeaderStyleGuide.enforce(on: view)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        switch indexPath.section {
        case 1 where me && indexPath.row != queuerows: return .delete
        case 2 where indexPath.row != requestrows,
             3 where indexPath.row != radiorows,
             4: return .insert
        default: return .none
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
//        if proposedDestinationIndexPath.section == sourceIndexPath.section {
//            return proposedDestinationIndexPath
//        } else if proposedDestinationIndexPath.section < sourceIndexPath.section {
//            return IndexPath(row: 0, section: sourceIndexPath.section)
//        } else if proposedDestinationIndexPath.section > sourceIndexPath.section {
//            var approvedDestinationIndexPath = proposedDestinationIndexPath
//            approvedDestinationIndexPath.section = sourceIndexPath.section
//            switch sourceIndexPath.section {
//            case 1: approvedDestinationIndexPath.row = queuerows
//            case 2, 3: approvedDestinationIndexPath.row = 3
//            case 4: approvedDestinationIndexPath.row = fill.songs.count - 1
//            default: break
//            }
//            return approvedDestinationIndexPath
//        } else {
//            return sourceIndexPath
//        }
        
        switch sourceIndexPath.section {
        case 1:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 1 {
                approvedDestinationIndexPath.section = 1
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 1 {
                approvedDestinationIndexPath.section = 1
                approvedDestinationIndexPath.row = queuerows
            } else if proposedDestinationIndexPath.row > queuerows {
                approvedDestinationIndexPath.row = queuerows
            }
            return approvedDestinationIndexPath
        case 2:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 2 {
                approvedDestinationIndexPath.section = 2
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 2 {
                approvedDestinationIndexPath.section = 2
                approvedDestinationIndexPath.row = requestrows
            } else if proposedDestinationIndexPath.row > requestrows {
                approvedDestinationIndexPath.row = requestrows
            }
            return approvedDestinationIndexPath
        case 3:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 3 {
                approvedDestinationIndexPath.section = 3
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 3 {
                approvedDestinationIndexPath.section = 3
                approvedDestinationIndexPath.row = radiorows
            } else if proposedDestinationIndexPath.row > radiorows {
                approvedDestinationIndexPath.row = radiorows
            }
            return approvedDestinationIndexPath
        case 4:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 4 {
                approvedDestinationIndexPath.section = 4
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 4 {
                approvedDestinationIndexPath.section = 4
                approvedDestinationIndexPath.row = fill.songs.count - 1
            }
            return approvedDestinationIndexPath
        default: return sourceIndexPath
        }
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return me ? 5 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1 where queue.queue.isEmpty: return 1
        case 1 where !me: return queue.queue.count
        case 1: return queue.queue.count <= queuerows ? queue.queue.count : queuerows + 1
        case 2:
            if queue.requests.count < requestrows { requestrows = queue.requests.count }
            return queue.requests.isEmpty ? 0 : requestrows + 1
        case 3:
            if radio.songs.count < radiorows { radiorows = radio.songs.count }
            return radio.songs.isEmpty ? 0 : radiorows + 1
        case 4: return fill.songs.count
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
        case 1 where indexPath.row == queuerows:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "show more"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.textLabel?.textAlignment = .center
            return cell
        case 1:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: queue.queue[indexPath.row])
            return cell
        case 2 where indexPath.row == requestrows, 3 where indexPath.row == radiorows:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "see all"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.accessoryType = .disclosureIndicator
            return cell
        case 2:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: queue.requests[indexPath.row])
            cell.voteslabel.text = nil
            return cell
        case 3:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: radio.songs[indexPath.row])
            cell.voteslabel.text = nil
            return cell
        case 4:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: fill.songs[indexPath.row])
            cell.voteslabel.text = nil
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "now playing:"
        case 1: return "up next:"
        case 2: return "requests:"
        case 3: return "from: wave radio"
        case 4  where fill.owner != Identity.me:
            guard let owner = CliqueAPI.find(user: fill.owner) else { fallthrough }
            return "from: " + fill.name + " by @" + owner.username
        case 4: return "from: " + fill.name
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        case 1 where indexPath.row == queuerows: return false
        case 1: return queue.queue.isEmpty ? false : me || queue.listeners.contains(Identity.me)
        case 2 where indexPath.row == requestrows,
             3 where indexPath.row == radiorows: return false
        case 2, 3, 4: return true
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            
            switch editingStyle {
            case .delete:
                queue.queue.remove(at: indexPath.row)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                manager.update(queue: queue)
            case .insert, .none: break
            }
            
        case 2:
            
            switch editingStyle {
            case .insert:
                let added = queue.requests[indexPath.row]
                manager.update(requests: queue.requests)
                manager.add(song: added)
                queue.requests.remove(at: indexPath.row)
                queue.queue.append(added)
                tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            case .delete, .none: break
            }
            
        case 3:
            
            switch editingStyle {
            case .insert:
                let added = radio.songs[indexPath.row]
                manager.add(song: added)
                radio.songs.remove(at: indexPath.row)
                queue.queue.append(added)
                tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            case .delete, .none: break
            }
            
        case 4:
            
            switch editingStyle {
            case .insert:
                let added = fill.songs[indexPath.row]
                manager.add(song: added)
                fill.songs.remove(at: indexPath.row)
                queue.queue.append(added)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            case .delete, .none: break
            }
            
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        case 1 where indexPath.row == queuerows: return false
        case 1: return queue.queue.isEmpty ? false : !queue.voting && (me || queue.listeners.contains(Identity.me))
        case 2 where indexPath.row == requestrows,
             3 where indexPath.row == radiorows: return false
        case 2, 3, 4: return true
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch sourceIndexPath.section {
        case 1:
            let mover = queue.queue[sourceIndexPath.row]
            queue.queue.remove(at: sourceIndexPath.row)
            queue.queue.insert(mover, at: destinationIndexPath.row)
            manager.update(queue: queue)
        case 2:
            let mover = queue.requests[sourceIndexPath.row]
            queue.requests.remove(at: sourceIndexPath.row)
            queue.requests.insert(mover, at: destinationIndexPath.row)
        case 3:
            let mover = radio.songs[sourceIndexPath.row]
            radio.songs.remove(at: sourceIndexPath.row)
            radio.songs.insert(mover, at: destinationIndexPath.row)
        case 4:
            let mover = fill.songs[sourceIndexPath.row]
            fill.songs.remove(at: sourceIndexPath.row)
            fill.songs.insert(mover, at: destinationIndexPath.row)
        default: break
        }
    }
    
}
