//
//  SongQueueTableView.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class QueueDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {

    //MARK: - properties

    var me: Bool {
        return QueueManager.sharedInstance().client() == Identity.sharedInstance().me
    }
    var queue: Queue {
        return QueueManager.sharedInstance().client()?.queue ?? Queue()
    }
    var fill: Playlist? {
        return QueueManager.sharedInstance().fill
    }

    //MARK: - table delegate methods
    
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
        case 1 where tableView.cellForRow(at: indexPath) is QueueSongTableViewCell:
            let up = UITableViewRowAction(style: .default, title: "+") { [weak self] (action, indexpath) in
                if let song = self?.queue.queue[indexPath.row] {
                    QueueManager.sharedInstance().vote(song: song, .up)
                }
            }
            
            let down = UITableViewRowAction(style: .default, title: "-") { [weak self] (action, indexpath) in
                if let song = self?.queue.queue[indexPath.row] {
                    QueueManager.sharedInstance().vote(song: song, .down)
                }
            }
            
            up.backgroundColor = UIColor.orange
            down.backgroundColor = UIColor.lightGray
            
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
        case 1 where me && !queue.queue.isEmpty: return .delete
        case 2: return .insert
        default: return .none
        }
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
    
    //MARK: - table data source methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return me && fill != nil ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return queue.queue.isEmpty ? 1 : queue.queue.count
        case 2 where fill != nil: return fill!.songs.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return NowPlayingTableViewCell(song: queue.current)
        case 1 where queue.queue.isEmpty:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "No songs"
            cell.detailTextLabel?.text = "Tap + to add a song to the queue"
            cell.accessoryType = .none
            return cell
        case 1:
            return QueueSongTableViewCell(song: queue.queue[indexPath.row])
        case 2 where fill != nil:
            let cell = QueueSongTableViewCell(song: fill!.songs[indexPath.row])
            cell.voteslabel.text = ""
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Now Playing"
        case 1: return "Up Next"
        case 2 where fill != nil:
            if let owner = CliqueAPIUtility.find(user: fill!.owner), owner != Identity.sharedInstance().me {
                return "From " + fill!.name + " by " + owner.username
            } else {
                return "From " + fill!.name
            }
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 1: return me
        case 2: return me
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch editingStyle {
            case .delete:
                var result = queue
                result.queue.remove(at: indexPath.row)
                QueueManager.sharedInstance().update(to: result)
            case .insert: break
            case .none: break
            }
        case 2 where fill != nil:
            switch editingStyle {
            case .insert: QueueManager.sharedInstance().add(song: fill!.songs[indexPath.row])
            case .delete: break
            case .none: break
            }
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 1: return me
        case 2: return me
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch sourceIndexPath.section {
        case 1:
            var result = queue
            let mover = queue.queue[sourceIndexPath.row]
            result.queue.remove(at: sourceIndexPath.row)
            result.queue.insert(mover, at: destinationIndexPath.row)
            QueueManager.sharedInstance().update(to: result)
        case 2:
            guard var result = fill else { return }
            let mover = result.songs[sourceIndexPath.row]
            result.songs.remove(at: sourceIndexPath.row)
            result.songs.insert(mover, at: destinationIndexPath.row)
            try? QueueManager.manage(fill: result)
        default: break
        }
    }
}
