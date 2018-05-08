//
//  FrequencyDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 4/3/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class FrequencyDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - properties
    
    var frequencies = [User]()
    var selection = -1
    
    //MARK: - initializers
    
    override init() {
        super.init()
        populate()
    }
    
    //MARK: - actions
    
    func populate() {
        guard let me = CliqueAPI.find(user: Identity.me) else { return }
        frequencies.removeAll()
        selection = -1
        
        frequencies.append(me)
        frequencies.append(contentsOf: np.frequencies)
        
        for i in frequencies.indices {
            if frequencies[i] == q.manager?.client() {
                selection = i
                break
            }
        }
        
    }
    
    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ip = IndexPath(row: selection, section: 0)
        selection = -1
        tableView.reloadRows(at: [ip], with: .none)
        gm?.hide(frequencies: ())
        if frequencies[indexPath.row].me() { gm?.stop(listening: ()) }
        else { gm?.listen(to: frequencies[indexPath.row].id, redirect: false) }
        q.refresh()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    /*func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }*/
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "friends sharing"
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frequencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "frequency") ?? UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let selected = selection == indexPath.row
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
        
        let current = frequencies[indexPath.row].queue.current
        
        cell.textLabel?.text = "@" + frequencies[indexPath.row].username
        cell.detailTextLabel?.text = current == nil ? nil : "🔊" + current!.artist.name + " - " + current!.title
        
        return cell
    }
    
}
