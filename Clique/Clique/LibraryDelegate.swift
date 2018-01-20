//
//  LibraryDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 1/12/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation
import UIKit

protocol LibraryDelegate: LibraryTableViewDelegate, LibraryTableViewDataSource {}

protocol LibraryTableViewDelegate: UITableViewDelegate {}
protocol LibraryTableViewDataSource: UITableViewDataSource {}

extension LibraryTableViewDelegate {
    
    var me: Bool {
        return LibraryManager.sharedInstance().client() == Identity.sharedInstance().me
    }
    var display: Any {
        return LibraryManager.sharedInstance().display ?? LibraryManager.sharedInstance().client().library
    }
    var adding: Bool {
        return LibraryManager.sharedInstance().adding
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch display {
        case let display as Playlist:
            LibraryManager.sharedInstance().play(playlist: display, at: indexPath.row)
        case is [Playlist] where indexPath.section == 0:
            LibraryManager.sharedInstance().viewAllSongs()
        case let display as [Playlist] where indexPath.section == 1:
            LibraryManager.sharedInstance().view(playlist: display[indexPath.row])
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        switch display {
        case is Playlist where adding: return .insert
        case is Playlist where !adding && me: return .delete
        case is [Playlist] where indexPath.section == 1 && me: return .delete
        default: return .none
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        switch display {
        case is [Playlist] where proposedDestinationIndexPath.section == 0: return IndexPath(row: 0, section: 1)
        default: return proposedDestinationIndexPath
        }
    }
    
}

extension LibraryTableViewDataSource {
    
    var me: Bool {
        return LibraryManager.sharedInstance().client() == Identity.sharedInstance().me
    }
    var display: Any {
        return LibraryManager.sharedInstance().display ?? LibraryManager.sharedInstance().client().library
    }
    var adding: Bool {
        return LibraryManager.sharedInstance().adding
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch display {
        case is Playlist: return 1
        case is [Playlist]: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch display {
        case let display as Playlist: return display.songs.count
        case let display as [Playlist]: return section == 0 ? 1 : display.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch display {
        case let display as Playlist:
            let cell = QueueSongTableViewCell(song: display.songs[indexPath.row])
            cell.voteslabel.text = ""
            return cell
        case is [Playlist] where indexPath.section == 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "All Songs"
            cell.accessoryType = .disclosureIndicator
            return cell
        case let display as [Playlist] where indexPath.section == 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = display[indexPath.row].name
            cell.detailTextLabel?.text = display[indexPath.row].songs.count.description + " songs"
            cell.accessoryType = .disclosureIndicator
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch display {
        case is Playlist: return me
        case is [Playlist]: return indexPath.section == 0 ? false : me
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch display {
        case var display as Playlist:
            
            switch editingStyle {
            case .delete:
                display.songs.remove(at: indexPath.row)
                LibraryManager.sharedInstance().update(with: [display])
            case .insert:
                LibraryManager.sharedInstance().queue(song: display.songs[indexPath.row])
            case .none: break
            }
            
        case var display as [Playlist]:
            display.remove(at: indexPath.row)
            LibraryManager.sharedInstance().update(to: display)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch display {
        case is [Playlist]: return indexPath.section == 0 ? false : me
        default: return me
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch display {
        case var display as Playlist:
            let mover = display.songs[sourceIndexPath.row]
            display.songs.remove(at: sourceIndexPath.row)
            display.songs.insert(mover, at: destinationIndexPath.row)
            LibraryManager.sharedInstance().update(with: [display])
        case var display as [Playlist]:
            let mover = display[sourceIndexPath.row]
            display.remove(at: sourceIndexPath.row)
            display.insert(mover, at: destinationIndexPath.row)
            LibraryManager.sharedInstance().update(to: display)
        default: break
        }
    }
}
