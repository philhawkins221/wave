//
//  ProfileBar.swift
//  Clique
//
//  Created by Phil Hawkins on 12/5/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class ProfileBar: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var usernamelabel: UIButton!
    @IBOutlet weak var sublinelabel: UILabel!
    @IBOutlet weak var profpic: UIImageView!
    @IBOutlet weak var opencloselabel: UIButton!
    
    var controller: VCid = .np
    var client: User?
    
    override init(frame: CGRect) { //editing in code
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) { //editing in interface builder
        super.init(coder: aDecoder)
        create()
    }
    
    private func create() {
        Bundle.main.loadNibNamed("ProfileBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        usernamelabel.contentVerticalAlignment = .bottom
        
        profpic.layer.cornerRadius = profpic.frame.size.width / 2
        profpic.clipsToBounds = true
    }
    
    func manage(profile: User) {
        client = profile
        
        display(username: profile.username)
        
        switch controller {
        case .lib:
            if profile.username == "anonymous" && profile.me() {
                display(subline: .createUsername)
            } else {
                display(subline: .generic)
            }
        case .np:
            if profile.username == "anonymous" && profile.me() {
                display(subline: .createUsername)
            } else {
                display(subline: .generic)
            }
        case .q:
            if profile.username == "anonymous" && profile.me() {
                display(subline: .createUsername)
            } else {
                display(subline: .generic)
            }
        }
    }
    
    func display(username: String) {
        DispatchQueue.main.async { [unowned self] in
            self.usernamelabel.setTitle("@" + username, for: .normal)
        }
    }
    
    func display(subline: Message) {
        let execute: () -> ()
        
        switch subline {
        case .generic:
            execute = { [unowned self] in
                self.sublinelabel.text = Message.generic.rawValue
            }
            
        case .peopleListening:
            if let client = client {
                execute = { [unowned self] in self.sublinelabel.text = client.queue.listeners.count.description + " people listening" }
            } else {
                execute = { [unowned self] in self.sublinelabel.text = "0 people listening" }
            }
                
        case .nowPlaying:
            if let current = client?.queue.current {
                execute = { [unowned self] in self.sublinelabel.text = "🔊" + current.artist.name + " - " + current.title }
            } else {
                display(subline: .generic)
                execute = { return }
            }
                
        case .requests: execute = { return }
            
        case .createUsername:
            execute = { [unowned self] in self.sublinelabel.text = Message.createUsername.rawValue }
            
        case .listening:
            if let leader = QueueManager.sharedInstance().client(), !leader.me() {
                execute = { [unowned self] in self.sublinelabel.text = "listening to @" + leader.username }
            } else if let leader = QueueManager.sharedInstance().client(), leader.me() {
                display(subline: .nowPlaying)
                execute = { return }
            } else {
                display(subline: .generic)
                execute = { return }
            }
        }
        
        DispatchQueue.main.async { execute() }
    }
    
    @IBAction func usernametap(_ sender: Any) {
        guard let client = client else { return }
        
        switch client.me() {
        case true:
            let alert = AlertsUtility.textField(title: "", entry: client.username) { [unowned self] (action, alert) in
                guard let name = alert.textFields?.first?.text else { return }
                var replacement = client.clone()
                replacement.username = name
                
                CliqueAPIUtility.update(user: replacement)
                self.display(username: name)
            }
            switch controller {
        case .lib:
            LibraryManager.sharedInstance().controller?.present(alert, animated: true)
        case .np:
            GeneralManager.sharedInstance().controller?.present(alert, animated: true)
        case .q:
            QueueManager.sharedInstance().controller?.present(alert, animated: true)
        }
        case false: break
        }
    }
    
    @IBAction func openclose(_ sender: Any) {
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
