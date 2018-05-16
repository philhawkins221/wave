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
    
    var controller: UIViewController? { return manager.profilebar?.controller }
    
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
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, manager.selections.contains(indexPath.row) {
            guard let i = manager.selections.index(of: indexPath.row) else { return }
            manager.selections.remove(at: i)
        }
        
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        return view
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "options") ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let selected = manager.selections.contains(indexPath.row)
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
            
            if indexPath.row == 0 && indexPath.row == options.count - 1 {
                let all = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)
                let layer = CAShapeLayer()
                
                layer.masksToBounds = true
                layer.frame = cell.bounds
                layer.path = all.cgPath
                cell.layer.mask = layer
            } else if indexPath.row == 0 {
                let top = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
                let layer = CAShapeLayer()
                
                layer.masksToBounds = true
                layer.frame = cell.bounds
                layer.path = top.cgPath
                cell.layer.mask = layer
            } else if indexPath.row == options.count - 1 {
                let bottom = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
                let layer = CAShapeLayer()
                
                layer.masksToBounds = true
                layer.frame = cell.bounds
                layer.path = bottom.cgPath
                cell.layer.mask = layer
            }
            
            switch options[indexPath.row] {
            case .settings:
                cell.textLabel?.text = "settings"
                cell.detailTextLabel?.text = "view and adjust settings"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .friendRequests:
                let requests = CliqueAPI.find(user: Identity.me)?.requests ?? []
                let count = requests.count.description
                cell.textLabel?.text = "friend requests"
                cell.detailTextLabel?.text =
                    requests.count > 1 ?
                        count + " new requests" :
                        requests.count > 0 ?
                            "from: @" + (CliqueAPI.find(user: requests.first!.sender)?.username ?? "") :
                            nil
                if requests.count > 0 { cell.detailTextLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) }
                cell.accessoryType = .disclosureIndicator
                return cell
            case .checkFrequencies:
                let frequencies = gm?.controller.frequencies ?? []
                cell.textLabel?.text = "check frequencies"
                cell.detailTextLabel?.text =
                    frequencies.isEmpty ?
                        "see who is sharing" :
                        frequencies.count > 1 ?
                            frequencies.count.description + " friends sharing" :
                            "@" + frequencies.first!.username + " is sharing"
                if !frequencies.isEmpty { cell.detailTextLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) }
                cell.accessoryType = .disclosureIndicator
                return cell
            case .shareQueue:
                let dnd = q.manager?.client().queue.donotdisturb ?? false
                let listeners = q.manager?.client().queue.listeners.count ?? 0
                cell.textLabel?.text = listeners > 0 ? listeners == 1 ? listeners.description + " person listening" : listeners.description + " people listening" : "share queue"
                cell.detailTextLabel?.text = dnd ? "do not disturb enabled" : "invite a friend to the queue"
                if dnd {
                    cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                    cell.selectionStyle = .none
                }
                cell.accessoryType = .disclosureIndicator
                return cell
            case .shuffle:
                cell.textLabel?.text = "shuffle " + (q.manager?.delegate?.fill.name ?? "")
                cell.detailTextLabel?.text = selected ? "playing songs in random order" : "playing songs in playlist order"
                cell.accessoryType = .none
                return cell
            case .addSong:
                let requestsonly = q.manager?.client().queue.requestsonly ?? false
                cell.textLabel?.text = requestsonly ? "request song" : "add song"
                cell.detailTextLabel?.text = requestsonly ? "request a song" : "add a song to the queue"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .addFriend:
                cell.textLabel?.text = "add friend"
                cell.detailTextLabel?.text = "send a friend request"
                cell.accessoryType = .disclosureIndicator
                return cell
            case .removeFriend:
                guard let controller = controller as? BrowseViewController,
                    let nofriends = controller.manager?.client().friends.isEmpty else { return cell }
                if nofriends {
                    cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                    cell.selectionStyle = .none
                }
                cell.textLabel?.text = "remove friend"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .disclosureIndicator
                return cell
            case .addPlaylist:
                cell.textLabel?.text = "add playlist"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .disclosureIndicator
                return cell
            case .removePlaylist:
                guard let controller = controller as? BrowseViewController,
                    let noplaylists = controller.manager?.client().library.isEmpty else { return cell }
                if noplaylists {
                    cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                    cell.selectionStyle = .none
                }
                cell.textLabel?.text = "remove playlist"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .disclosureIndicator
                return cell
            case .joinQueue:
                guard let controller = controller as? BrowseViewController,
                      let client = controller.manager?.client() else { return cell }
                let listening = !client.me() && client == q.manager?.client()
                let dnd = client.queue.donotdisturb
                cell.textLabel?.text = listening ? "leave queue" : "join queue"
                cell.detailTextLabel?.text = dnd ? "do not disturb enabled" : listening ? " stop listening with @" + client.username : "listen with @" + client.username
                if dnd {
                    cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                    cell.selectionStyle = .none
                }
                cell.accessoryType = .none
                return cell
            case .addUser:
                guard let controller = controller as? BrowseViewController else { return cell }
                cell.textLabel?.text = "add friend"
                switch controller.manager?.client().username {
                case .some(let user): cell.detailTextLabel?.text = "send @" + user + " a friend request"
                case nil: cell.detailTextLabel?.text = "send this user a friend request"
                }
                cell.accessoryType = .none
                return cell
            case .playPlaylist:
                cell.textLabel?.text = "play"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
                return cell
            case .addPlaylistToLibrary:
                cell.textLabel?.text = "add playlist to library"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
                return cell
            case .sharePlaylist:
                cell.textLabel?.text = selected ? "sharing playlist" : "share playlist"
                cell.detailTextLabel?.text = selected ? "others can view and add this playlist" : "only you can view this playlist"
                cell.accessoryType = .none
                return cell
            case .playAll:
                cell.textLabel?.text = "play all"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
                return cell
            case .playCatalog:
                cell.textLabel?.text = "play"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
                return cell
            case .addCatalogToLibrary:
                cell.textLabel?.text = "add to library"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
                return cell
            case .addHistoryPlaylist:
                cell.textLabel?.text = "new playlist from history"
                cell.detailTextLabel?.text = nil
                cell.accessoryType = .none
                return cell
            case .stopSharing, .stopListening, .stopViewing, .stopSyncing, .none: return cell
            }
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stop") ?? UITableViewCell(style: .default, reuseIdentifier: nil)
            let selectedview = UIView()
            selectedview.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.selectedBackgroundView = selectedview
            
            let all = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)
            let layer = CAShapeLayer()
            
            layer.masksToBounds = true
            layer.frame = cell.bounds
            layer.path = all.cgPath
            cell.layer.mask = layer
            
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
                , .addSong, .addFriend, .removeFriend, .addPlaylist, .removePlaylist, .joinQueue, .addUser, .playPlaylist, .addPlaylistToLibrary, .sharePlaylist, .playAll, .playCatalog, .addCatalogToLibrary, .addHistoryPlaylist, .none:
                return cell
            }
            
        default: return UITableViewCell()
        }
    }
    
}
