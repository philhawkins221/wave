//
//  SocialDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class SocialDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - properties
    
    var requests: [Request] = []
    var senders: [User] = []
    
    //MARK: - initializers
    
    override init() {
        super.init()
        populate()
    }
    
    func populate() {
        requests = CliqueAPI.find(user: Identity.me)?.requests ?? []
        var senders = [User]()
        for request in requests {
            if let sender = CliqueAPI.find(user: request.sender) {
                senders.append(sender)
            }
        }
        self.senders = senders
    }
    
    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if requests.isEmpty { return }
        gm?.respond(to: requests[indexPath.row])
        requests.remove(at: indexPath.row)
        senders.remove(at: indexPath.row)
        if !requests.isEmpty { tableView.deleteRows(at: [indexPath], with: .automatic) }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.isEmpty ? 1 : requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        if requests.isEmpty {
            cell.textLabel?.text = "no requests"
            cell.detailTextLabel?.text = "new requests will appear here"
            return cell
        }
        
        cell.textLabel?.text = "from: @" + senders[indexPath.row].username
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.text = "tap to open"
        cell.detailTextLabel?.textColor = UIColor.orange
        return cell
    }
    
}
