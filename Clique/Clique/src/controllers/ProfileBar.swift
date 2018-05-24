//
//  ProfileBar.swift
//  Clique
//
//  Created by Phil Hawkins on 12/5/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class ProfileBar: UIView {
    
    //MARK: - storyboard outlets

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var usernamelabel: UIButton!
    @IBOutlet weak var sublinelabel: UILabel!
    @IBOutlet weak var profpic: UIImageView!
    @IBOutlet weak var opencloselabel: UIButton!
    
    //MARK: - properties
    
    var controller = UIViewController()
    var client: User?
    
    var optionscontainer: UIView?
    var optionscover: UIView?
    var options: OptionsTableViewController?
    
    enum Message {
        case generic
        case peopleListening
        case nowPlaying
        case requests
        case frequencies
        case viewing
        case listening
        case listeningTo
        case createUsername
        case streaming
        case streamingUser
    }
    
    var message: Message {
        guard let client = client else { return .generic }
        
        switch client.me() {
        case true:
            if client.username == "anonymous" { return .createUsername }
            
            switch controller {
            case is NowPlayingViewController:
                if (q.manager?.client().me() ?? false) && client.queue.listeners.count > 0 {
                    return .peopleListening
                } else if !(q.manager?.client().me() ?? true) && Media.playing {
                    return .streamingUser
                } else if !(q.manager?.client().me() ?? true) {
                    return .listeningTo
                } else if gm?.check(requests: (), cached: false) ?? false {
                    return .requests
                } else if (gm?.controller.frequencies ?? []).count > 0 {
                    return .frequencies
                } else if gm?.display != nil {
                    return .nowPlaying
                } else {
                    return .generic
                }
            case is BrowseViewController, is QueueViewController:
                if (q.manager?.client().me() ?? false) && client.queue.listeners.count > 0 {
                    return .peopleListening
                } else if !(q.manager?.client().me() ?? true) && Media.playing {
                    return controller is QueueViewController ? .streaming : .streamingUser
                } else if !(q.manager?.client().me() ?? true) {
                    return controller is QueueViewController ? .listening : .listeningTo
                } else if gm?.display != nil {
                    return .nowPlaying
                } else {
                    return .generic
                }
            default: return .generic
            }
        case false:
            switch controller {
            case is BrowseViewController: return .viewing
            case is QueueViewController where !(q.manager?.client().me() ?? true) && Media.playing: return .streaming
            case is QueueViewController: return .listening
            default: return .generic
            }
        }
    }
    
    //MARK: - initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
    //MARK: - factory
    
    private func create() {
        Bundle.main.loadNibNamed("ProfileBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        usernamelabel.contentVerticalAlignment = .bottom
        
        profpic.layer.cornerRadius = profpic.frame.size.width / 2
        profpic.clipsToBounds = true
    }
    
    //MARK: - actions
    
    func manage(profile: User) {
        client = profile
        
        display(username: profile.username)
        display(subline: message)
    }
    
    func display(username: String) {
        DispatchQueue.main.async { [unowned self] in
            self.usernamelabel.setTitle("@" + username, for: .normal)
        }
    }
    
    func display(subline: Message) {
        var message = String()
        
        switch subline {
        case .peopleListening:
            let listeners = client?.queue.listeners.count ?? 0
            message = listeners > 1 ? listeners.description + " people listening" : listeners.description + " person listening"
        case .nowPlaying:
            guard let current = client?.queue.current else { return }
            message = "🔊" + current.artist.name + " - " + current.title
        case .frequencies:
            let frequencies = gm?.controller.frequencies ?? []
            let count = frequencies.count.description
            message = frequencies.count > 1 ? count + " people sharing" : "@" + (frequencies.first?.username ?? "") + " is sharing"
        case .requests:
            let requests = client?.requests.count ?? 0
            message = requests > 1 ? requests.description + " new requests" : requests.description + " new request"
        case .createUsername: message = "tap to change"
        case .viewing: message = "viewing"
        case .listening: message = "listening"
        case .listeningTo:
            guard let leader = q.manager?.client() else { return }
            message = "listening to @" + leader.username
        case .streaming: message = "streaming"
        case .streamingUser:
            guard let leader = q.manager?.client() else { return }
            message = "streaming @" + leader.username
        case .generic: message = "start a wave"
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.sublinelabel.text = message
        }
    }
    
    //MARK: - storyboard actions
    
    @IBAction func usernametap(_ sender: Any) {
        guard let client = client else { return }
        if client.me() { Alerts.rename(user: self, on: controller) }
    }
    
    @IBAction func openclose(_ sender: Any) {
        switch opencloselabel.title(for: .normal) ?? "" {
        case "⬆️":
            Options.assess(for: controller)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(openclose(_:)))
            let height = NSLayoutConstraint(item: optionscontainer!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(Options.height))
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blur.frame = optionscover?.bounds ?? CGRect()
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            options?.refresh()
            optionscontainer?.addConstraint(height)
            optionscover?.addGestureRecognizer(tap)
            
            if !UIAccessibilityIsReduceTransparencyEnabled() { optionscover?.addSubview(blur) }
            else { optionscover?.backgroundColor = .white }
            
            optionscover?.alpha = 0
            optionscontainer?.alpha = 0
            
            let center = optionscontainer?.center ?? CGPoint()
            optionscontainer?.center = CGPoint(x: center.x, y: center.y + 50)
            
            optionscover?.isHidden = false
            optionscontainer?.isHidden = false
            
            UIView.animate(withDuration: 0.15) { [weak self] in
                self?.optionscover?.alpha = 0.8
                self?.optionscontainer?.alpha = 0.9
                self?.optionscontainer?.center = center
            }
            
            opencloselabel.setTitle("⬇️", for: .normal)
        
        case "⬇️":
            optionscontainer?.removeConstraints(optionscontainer!.constraints)
            UIView.animate(withDuration: 0.15, animations: { [weak self] in
                self?.controller.view.layoutIfNeeded()
                self?.optionscover?.alpha = 0
                self?.optionscontainer?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.optionscover?.isHidden = true
                self?.optionscontainer?.isHidden = true
                if let tap = self?.optionscover?.gestureRecognizers?.first {
                    self?.optionscover?.removeGestureRecognizer(tap)
                }
            })
            
            opencloselabel.setTitle("⬆️", for: .normal)
        default: break
        }
    }

}
