//
//  SharingDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/29/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class SharingDelegate: SettingsDelegate {
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        
        selections = (client?.library ?? []).map { $0.social }
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard let client = client else { return }
            selections[indexPath.row] = !selections[indexPath.row]
            var replacement = client.library[indexPath.row]
            replacement.social = selections[indexPath.row]
            CliqueAPI.update(playlist: Identity.me, with: replacement)
            tableView.reloadRows(at: [indexPath], with: .none)
        default: tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return client?.library.count ?? 0
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = " "
            cell.detailTextLabel?.text = "playlists"
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.backgroundColor = UIColor.groupTableViewBackground
            cell.selectionStyle = .none
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 1:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = selections[indexPath.row]
            cell.textLabel?.text = client?.library[indexPath.row].name ?? ""
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.detailTextLabel?.textColor = selected ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.detailTextLabel?.text = selected ? "sharing" : "private"
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            
            switch client?.library[indexPath.row].library ?? "" {
            case Catalogues.AppleMusic.rawValue: cell.imageView?.image = #imageLiteral(resourceName: "apple music logo.jpg")
            case Catalogues.Spotify.rawValue: cell.imageView?.image = #imageLiteral(resourceName: "spotify logo.jpg")
            default: cell.imageView?.image = nil
            }
            cell.setImageSize(to: 40)
            return cell
            
        default: return UITableViewCell()
        }
    }
    
}
