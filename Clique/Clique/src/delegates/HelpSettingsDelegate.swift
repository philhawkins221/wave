//
//  HelpSettingsDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 5/16/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class HelpSettingsDelegate: SettingsDelegate {
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath.row {
        case 0: controller.present(nphelpvc!, animated: true)
        case 1: controller.present(qhelpvc!, animated: true)
        case 2: controller.present(brohelpvc!, animated: true)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return 3
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "now playing help"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "queue help"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case 2:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "browse help"
            cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        default: return UITableViewCell()
        }
    }
}
