//
//  QueueSettingsDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class QueueSettingsDelegate: SettingsDelegate {
    
    //MARK: - properties
    
    let listeners: [Setting] = [.requestsonly, .takerequests, .voting]
    let auto: [Setting] = [.radio, .shuffle]
    
    var dndselect = false
    var listenerselect = [Bool]()
    var autoselect = [Bool]()
    
    //MARK: - actions
    
    override func populate() {
        super.populate()
        
        dndselect = Settings.donotdisturb
        
        listenerselect = [
            Settings.requestsonly,
            Settings.takerequests,
            Settings.voting
        ]
        
        autoselect = [
            Settings.radio,
            Settings.shuffle
        ]
    }
    
    //MARK: - table delegate stack
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            dndselect = !dndselect
            Settings.update(.donotdisturb)
            tableView.reloadRows(at: [indexPath], with: .none)
        case 2:
            listenerselect[indexPath.row] = !listenerselect[indexPath.row]
            if listeners[indexPath.row] == .requestsonly && listenerselect[indexPath.row] {
                if let i = listeners.index(of: .takerequests) { listenerselect[i] = true }
            }
            Settings.update(listeners[indexPath.row])
            tableView.reloadSections(IndexSet(integer: 2), with: .none)
        case 3:
            autoselect[indexPath.row] = !autoselect[indexPath.row]
            Settings.update(auto[indexPath.row])
            tableView.reloadRows(at: [indexPath], with: .none)
        case 5:
            let simulate = IndexPath(row: indexPath.row, section: 1)
            super.tableView(UITableView(), didSelectRowAt: simulate)
            tableView.reloadRows(at: [indexPath], with: .none)
        case 6 where stop == .delete: controller.kill()
        case 6: Settings.update(stop); fallthrough
        default: tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 3, 4, 6: return 0
        default: return 60
        }
    }
    
    //MARK: - table data source stack
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 0
        case 1: return 1
        case 2: return 3
        case 3: return 2
        case 4: return 1
        case 5: return 2
        case 6: return stop == .none ? 0 : 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = dndselect
            cell.textLabel?.text =  "do not disturb"
            cell.detailTextLabel?.text = "prevent friends from joining the queue"
            cell.textLabel?.textColor = UIColor.black
            cell.imageView?.image = nil
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 2 where listeners[indexPath.row] == .requestsonly:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = listenerselect[indexPath.row]
            cell.textLabel?.text =  "requests only"
            cell.detailTextLabel?.text = "prevent listeners from editing up next"
            cell.textLabel?.textColor = UIColor.black
            cell.imageView?.image = nil
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 2 where listeners[indexPath.row] == .takerequests:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = listenerselect[indexPath.row]
            cell.textLabel?.text =  "automatically take requests"
            cell.detailTextLabel?.text = "play song requests if up next is empty"
            cell.textLabel?.textColor = UIColor.black
            cell.imageView?.image = nil
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 2 where listeners[indexPath.row] == .voting:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = listenerselect[indexPath.row]
            cell.textLabel?.text =  "voting"
            cell.detailTextLabel?.text = nil
            cell.textLabel?.textColor = UIColor.black
            cell.imageView?.image = nil
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 3 where auto[indexPath.row] == .radio:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = autoselect[indexPath.row]
            cell.textLabel?.text =  "wave radio"
            cell.textLabel?.textColor = UIColor.black
            cell.imageView?.image = nil
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 3 where auto[indexPath.row] == .shuffle:
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "setting")
            let cell = tableView.dequeueReusableCell(withIdentifier: "setting") as! SettingsTableViewCell
            let selected = autoselect[indexPath.row]
            cell.textLabel?.text = "shuffle"
            cell.textLabel?.textColor = UIColor.black
            cell.imageView?.image = nil
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .none
            cell.slider.isOn = selected
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        case 4, 5:
            let simulate = IndexPath(row: indexPath.row, section: indexPath.section - 4)
            return super.tableView(tableView, cellForRowAt: simulate)
            
        case 6:
            let simulate = IndexPath(row: indexPath.row, section: indexPath.section - 3)
            return super.tableView(tableView, cellForRowAt: simulate)
            
        default: return UITableViewCell()
        }
    }
    
}
