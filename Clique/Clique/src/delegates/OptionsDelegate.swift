//
//  OptionsDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/24/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class OptionsDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - properties
    
    var manager: OptionsManager
    
    var options = [Option]()
    var stop: Option = .none
    
    //MARK: - initializers
    
    init(to manager: OptionsManager) {
        self.manager = manager
        self.options = Options.options.options
        if let stop = Options.options.stop { self.stop = stop }
    }
    
    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.isSelected ?? false
            { tableView.deselectRow(at: indexPath, animated: false) }
        
        switch indexPath.section {
        case 0: manager.execute(options[indexPath.row])
        case 1: manager.execute(stop)
        default: break
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    /*func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: manager.execute(options[indexPath.row])
        case 1: manager.execute(stop)
        default: break
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }*/
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        case 1: return stop == .none ? 0 : 20
        default: return 0
        }
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stop == .none ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return options.count
        case 1: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let selected = tableView.cellForRow(at: indexPath)?.isSelected ?? false
            let selectedview = UIView()
            selectedview.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.9649684176, green: 0.9649684176, blue: 0.9649684176, alpha: 1)
            cell.backgroundColor = selected ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            cell.selectedBackgroundView = selectedview
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            
            switch options[indexPath.row] {
            case .settings:
                cell.textLabel?.text = "settings"
                cell.detailTextLabel?.text = "view and adjust settings"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .friendRequests:
                cell.textLabel?.text = "friend requests"
                cell.detailTextLabel?.text = nil //TODO: gm requests
                cell.detailTextLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
                cell.accessoryType = .disclosureIndicator
                return cell
            case .checkFrequencies:
                cell.textLabel?.text = "check frequencies"
                cell.detailTextLabel?.text = "see who is sharing" //TODO: gm check frequencies
                //cell.detailTextLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
                cell.accessoryType = .disclosureIndicator
                return cell
            case .shareQueue:
                cell.textLabel?.text = "share queue"
                cell.detailTextLabel?.text = "invite a friend to the queue"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .shuffle:
                cell.textLabel?.text = "shuffle " + (q.manager?.delegate?.fill.name ?? "")
                cell.detailTextLabel?.text = selected ? "playing songs in random order" : "playing songs in playlist order"
                return cell
            case .addFriend:
                cell.textLabel?.text = "add friend"
                cell.detailTextLabel?.text = "send a friend request"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .removeFriend:
                cell.textLabel?.text = "remove friend"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .addPlaylist:
                cell.textLabel?.text = "add playlist"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .removePlaylist:
                cell.textLabel?.text = "remove playlist"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .joinQueue:
                cell.textLabel?.text = "join queue"
                return cell
            case .playPlaylist:
                cell.textLabel?.text = "play"
                return cell
            case .addPlaylistToLibrary:
                cell.textLabel?.text = "add playlist to library"
                return cell
            case .sharePlaylist:
                cell.textLabel?.text = selected ? "sharing playlist" : "share playlist"
                cell.detailTextLabel?.text = selected ? "others can view and add this playlist" : "only you can view this playlist"
                return cell
            case .playAll:
                cell.textLabel?.text = "play all"
                return cell
            case .playCatalog:
                cell.textLabel?.text = "play"
                return cell
            case .addCatalogToLibrary:
                cell.textLabel?.text = "add to library"
                return cell
            case .addHistoryPlaylist:
                cell.textLabel?.text = "new playlist from history"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .stopSharing, .stopListening, .stopViewing, .stopSyncing, .none: return cell
            }
            
        case 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let selectedview = UIView()
            selectedview.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.selectedBackgroundView = selectedview
            
            switch stop {
            case .stopSharing:
                cell.textLabel?.text = "stop sharing"
                return cell
            case .stopListening:
                cell.textLabel?.text = "stop listening"
                return cell
            case .stopViewing:
                cell.textLabel?.text = "stop viewing"
                return cell
            case .stopSyncing:
                cell.textLabel?.text = "stop syncing"
                return cell
            case .settings, .friendRequests, .checkFrequencies, .shareQueue, .shuffle
                , .addFriend, .removeFriend, .addPlaylist, .removePlaylist, .joinQueue, .playPlaylist, .addPlaylistToLibrary, .sharePlaylist, .playAll, .playCatalog, .addCatalogToLibrary, .addHistoryPlaylist, .none:
                return cell
            }
            
        default: return UITableViewCell()
        }
    }
    
}
