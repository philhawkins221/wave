//
//  SettingsDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class SettingsDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - properties
    
    var controller: SettingsViewController
    
    let connect: [Setting] = [.applemusic]
    var stop: Setting = .none
    var selections = [Bool]()
    var client: User?
    
    //MARK: - initializers
    
    init(to controller: SettingsViewController) {
        self.controller = controller
        super.init()
        
        populate()
    }
    
    //MARK: - actions
    
    func populate() {
        guard let client = CliqueAPI.find(user: Identity.me) else { return }
        let leader = q.manager?.client()
        Settings.update()
        
        if leader != nil, leader!.queue.current != nil && leader!.me() {
            stop = .stopSharing
        } else if leader != nil, leader!.queue.current != nil {
            stop = .stopListening
        } else {
            stop = .delete
        }
        
        selections = [
            Settings.applemusic,
            Settings.spotify
        ]
        
        self.client = client
    }
    
    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            Spotify.controller = controller
            selections[indexPath.row] = !selections[indexPath.row]
            Settings.update(connect[indexPath.row])
            selections[indexPath.row] = connect[indexPath.row] == .applemusic ? Settings.applemusic : Settings.spotify
            tableView.reloadRows(at: [indexPath], with: .none)
        case 2 where indexPath.row == 0: controller.view(settings: .sharing)
        case 2 where indexPath.row == 1: controller.view(settings: .queue)
        case 2 where indexPath.row == 2: controller.view(settings: .help)
        case 3 where stop == .delete: controller.kill()
        case 3: Settings.update(stop); fallthrough
        default: tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return 60
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 //connect accounts
        case 1: return connect.count //accounts
        case 2: return 3 //share playlists, queue settings, help
        case 3: return stop == .none ? 0 : 1 //stop
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = " "
            cell.detailTextLabel?.text = "connect accounts"
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.backgroundColor = UIColor.groupTableViewBackground
            cell.selectionStyle = .none
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        
        case 1 where connect[indexPath.row] == .applemusic:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = selections[indexPath.row]
            cell.textLabel?.text = selected ? "connected" : "connect Apple Music"
            cell.textLabel?.textColor = selected ? #colorLiteral(red: 0.5736985803, green: 0.3841053247, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.detailTextLabel?.text = nil
            cell.imageView?.image = #imageLiteral(resourceName: "apple music logo.jpg")
            cell.setImageSize(to: 40)
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 1 where connect[indexPath.row] == .spotify:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = selections[indexPath.row]
            cell.textLabel?.text = selected ? "connected" : "connect Spotify"
            cell.textLabel?.textColor = selected ? #colorLiteral(red: 0.1182995066, green: 0.8422558904, blue: 0.3786807954, alpha: 1) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.detailTextLabel?.text = nil
            cell.imageView?.image = #imageLiteral(resourceName: "spotify logo.jpg")
            cell.setImageSize(to: 40)
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 2 where indexPath.row == 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "share playlists"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.accessoryType = .disclosureIndicator
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 2 where indexPath.row == 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "queue settings"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.accessoryType = .disclosureIndicator
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 2 where indexPath.row == 2:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "help"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.accessoryType = .disclosureIndicator
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 3 where stop == .stopSharing:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "stop sharing"
            cell.textLabel?.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.textLabel?.textAlignment = .center
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 3 where stop == .stopListening:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "stop listening"
            cell.textLabel?.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.textLabel?.textAlignment = .center
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 3 where stop == .delete:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "delete @" + (client?.username ?? "")
            cell.textLabel?.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.textLabel?.textAlignment = .center
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        default:
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.groupTableViewBackground
            return cell
        }
    }
    
}
