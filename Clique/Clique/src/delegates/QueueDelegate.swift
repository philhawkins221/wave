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
    var radio = [Single]()
    
    var controller: QueueViewController { return manager.controller }
    var editing: Bool { return manager.controller.edit }
    var requestsonly: Bool { return queue.requestsonly }
    
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
        
        if (!me && requestsonly && queue.requests.isEmpty) || editing { queuerows = Int.max }
        if editing { manager.controller.setTabBarSwipe(enabled: false) }
        if queue.queue.isEmpty { queuerows = 1 }
        
        q.listeners.removeAll()
        queue.listeners.forEach {
            if let listener = CliqueAPI.find(user: $0) { q.listeners["id"] = listener.username }
        }
        
        radio = manager.controller.radio
        
        fill = Settings.shuffle ?
            manager.controller.shuffled ?? Playlist() :
            manager.controller.fill ?? Playlist()
    }
    
    func title() {}
    
    @objc func edit() {
        manager.controller.edit = !manager.controller.edit
        manager.controller.setTabBarSwipe(enabled: !manager.controller.edit)
        manager.refresh()
    }

    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 150
        case 1 where indexPath.row == queuerows,
             1 where me && indexPath.row == queue.queue.count && !queue.queue.isEmpty,
             2 where indexPath.row == requestrows,
             3 where indexPath.row == radiorows: return 30
        default: return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let current = queue.current else { return tableView.deselectRow(at: indexPath, animated: true) }
            Actions.view(nowplaying: current, on: controller)
        case 1 where indexPath.row == queuerows:
            queuerows += 5
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        case 1 where me && indexPath.row == queue.queue.count && !queue.queue.isEmpty: manager.delete(queue: ())
        case 1 where !queue.queue.isEmpty: Actions.view(song: indexPath.row, in: queue, on: controller)
        //case 1: Actions.view(song: queue.queue[indexPath.row], on: controller, queued: true)
        case 2 where indexPath.row == requestrows: manager.view(requests: ())
        case 2: Actions.view(song: queue.requests[indexPath.row], on: controller)
        case 3 where indexPath.row == radiorows: manager.view(radio: ())
        case 3: Actions.view(single: indexPath.row, on: controller)
        case 4:
            if Settings.shuffle, let song = q.shuffled?.songs[indexPath.row] { Actions.view(song: song, on: controller) }
            else if let song = q.fill?.songs[indexPath.row] { Actions.view(song: song, on: controller) }
        case 2, 3, 4: Actions.view(song: queue.queue[indexPath.row], on: controller)
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch indexPath.section {
        case 1 where !queue.queue.isEmpty && indexPath.row != queuerows && indexPath.row != queue.queue.count,
             2 where indexPath.row != requestrows:
            
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
                return [delete]
                return [up, down, delete]
            }
            
            return [up, down]
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            case 2 where queue.requests.isEmpty,
                 3 where radio.isEmpty,
                 4 where fill.songs.isEmpty: return 0
        default: return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 1, 4:
            tableView.register(UINib(nibName: "QueueHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "queue")
            let view = tableView.dequeueReusableCell(withIdentifier: "queue") as! QueueHeaderTableViewCell
            let client = manager.client()
            
            view.titlelabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            if !client.me() && client.queue.requestsonly { 
                view.editlabel.text = nil
            } else {
                view.edit.addTarget(self, action: #selector(edit), for: .touchUpInside)
                if editing {
                    view.editlabel.text = "editing"
                    view.contentView.backgroundColor = UIColor.orange
                }
            }
            return view.contentView
        default:
            let view = UITableViewHeaderFooterView()
            TableHeaderStyleGuide.enforce(on: view)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        switch indexPath.section {
        case 1 where editing && indexPath.row != queuerows && indexPath.row != queue.queue.count: return .delete
        case 2 where indexPath.row != requestrows,
             3 where indexPath.row != radiorows && me,
             4: return .insert
        default: return .none
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        switch sourceIndexPath.section {
        case 1 where editing || queuerows == -1:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 1 {
                approvedDestinationIndexPath.section = 1
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 1 {
                approvedDestinationIndexPath.section = 1
                approvedDestinationIndexPath.row = queue.queue.count - 1
            } else if proposedDestinationIndexPath.row >= queue.queue.count {
                approvedDestinationIndexPath.row = queue.queue.count - 1
            }
            return approvedDestinationIndexPath
            
        case 1:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 1 {
                approvedDestinationIndexPath.section = 1
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 1 {
                approvedDestinationIndexPath.section = 1
                approvedDestinationIndexPath.row = queuerows - 1
            } else if proposedDestinationIndexPath.row >= queuerows {
                approvedDestinationIndexPath.row = queuerows - 1
            }
            return approvedDestinationIndexPath
        
        case 2:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 2 {
                approvedDestinationIndexPath.section = 2
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 2 {
                approvedDestinationIndexPath.section = 2
                approvedDestinationIndexPath.row = requestrows - 1
            } else if proposedDestinationIndexPath.row >= requestrows {
                approvedDestinationIndexPath.row = requestrows - 1
            }
            return approvedDestinationIndexPath
       
        case 3:
            var approvedDestinationIndexPath = proposedDestinationIndexPath
            if proposedDestinationIndexPath.section < 3 {
                approvedDestinationIndexPath.section = 3
                approvedDestinationIndexPath.row = 0
            } else if proposedDestinationIndexPath.section > 3 {
                approvedDestinationIndexPath.section = 3
                approvedDestinationIndexPath.row = radiorows - 1
            } else if proposedDestinationIndexPath.row >= radiorows {
                approvedDestinationIndexPath.row = radiorows - 1
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
        return me ? 5 : requestsonly ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1 where queue.queue.isEmpty: return 1
        case 1: return queue.queue.count > queuerows ? queuerows + 1 : me ? queue.queue.count + 1 : queue.queue.count
        case 2:
            if queue.requests.count < requestrows { requestrows = queue.requests.count }
            return queue.requests.isEmpty ? 0 : requestrows + 1
        case 3:
            if radio.count < radiorows { radiorows = radio.count }
            return radio.isEmpty ? 0 : radiorows + 1
        case 4: return fill.songs.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            tableView.register(UINib(nibName: "NowPlayingTableViewCell", bundle: nil), forCellReuseIdentifier: "np")
            let cell = tableView.dequeueReusableCell(withIdentifier: "np") as! NowPlayingTableViewCell
            cell.set(song: queue.current)
            return cell
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
        case 1 where me && indexPath.row == queue.queue.count:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "remove all"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.textLabel?.textAlignment = .center
            return cell
        case 1:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(song: queue.queue[indexPath.row], voting: true, credit: me)
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
            cell.set(song: queue.requests[indexPath.row], voting: true, credit: me)
            return cell
        case 3:
            tableView.register(UINib(nibName: "QueueSongTableViewCell", bundle: nil), forCellReuseIdentifier: "song")
            let cell = tableView.dequeueReusableCell(withIdentifier: "song") as! QueueSongTableViewCell
            cell.set(single: radio[indexPath.row])
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
        case 1: return !queue.queue.isEmpty && indexPath.row != queue.queue.count
        case 2 where indexPath.row == requestrows || !me,
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
                if !queue.queue.isEmpty { tableView.deleteRows(at: [indexPath], with: .automatic) }
                manager.update(queue: queue)
            case .insert, .none: break
            }
            
        case 2:
            switch editingStyle {
            case .insert:
                let added = queue.requests[indexPath.row]
                queue.requests.remove(at: indexPath.row)
                manager.update(requests: queue.requests)
                manager.add(song: added)
                tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                queue.queue.append(added)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            case .delete, .none: break
            }
            
        case 3:
            switch editingStyle {
            case .insert:
                let added = radio[indexPath.row]
                manager.add(single: added)
                radio.remove(at: indexPath.row)
                q.radio = radio
                tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
            case .delete, .none: break
            }
            
        case 4 where Settings.shuffle:
            switch editingStyle {
            case .insert:
                let added = fill.songs[indexPath.row]
                manager.add(song: added)
                fill.songs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                queue.queue.append(added)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            case .delete, .none: break
            }
            
        case 4:
            switch editingStyle {
            case .insert:
                let added = fill.songs[indexPath.row]
                manager.add(song: added)
                fill.songs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                queue.queue.append(added)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                
                if Settings.shuffle { manager.controller.shuffled = fill }
                else { manager.controller.fill = fill }
            case .delete, .none: break
            }
            
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0: return false
        case 1 where indexPath.row == queuerows: return editing
        case 1 where me && indexPath.row == queue.queue.count: return false
        case 1: return queue.queue.isEmpty ? false : !queue.voting && editing
        case 2 where indexPath.row == requestrows || !me,
             3 where indexPath.row == radiorows: return false
        //case 2, 3, 4: return true
        case 4: return editing
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
            let mover = radio[sourceIndexPath.row]
            radio.remove(at: sourceIndexPath.row)
            radio.insert(mover, at: destinationIndexPath.row)
        case 4:
            let mover = fill.songs[sourceIndexPath.row]
            fill.songs.remove(at: sourceIndexPath.row)
            fill.songs.insert(mover, at: destinationIndexPath.row)
            if Settings.shuffle { manager.controller.shuffled = fill }
            else { manager.controller.fill = fill }
        default: break
        }
    }
    
}
