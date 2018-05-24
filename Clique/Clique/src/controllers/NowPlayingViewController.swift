//
//  NowPlayingViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 12/9/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit
import RSPlayPauseButton
import ASPVideoPlayer
import AVKit

class NowPlayingViewController: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var profilebar: ProfileBar!
    @IBOutlet weak var options: UIView!
    @IBOutlet weak var optionscover: UIView!
    
    @IBOutlet weak var waves: ASPVideoPlayerView!
    @IBOutlet weak var tuner: UIView!
    
    @IBOutlet weak var artworkimage: UIImageView!
    @IBOutlet weak var songlabel: UILabel!
    @IBOutlet weak var artistlabel: UILabel!
    @IBOutlet weak var creditlabel: UILabel!
    
    @IBOutlet weak var buttonsview: UIView!
    @IBOutlet weak var rewindbutton: UIButton!
    @IBOutlet weak var playpausebutton: RSPlayPauseButton!
    @IBOutlet weak var fastforwardbutton: UIButton!
    
    @IBOutlet weak var helplabel: UILabel!
    
    //MARK: - properties
    
    var manager: GeneralManager?
    
    var frequencies = [User]()
    var tunercontroller: FrequencyTableViewController?
    
    //MARK: - lifecycle stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = GeneralManager(to: self)
        profilebar.controller = self
        
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = artworkimage.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.alpha = 0.7
        artworkimage.addSubview(blur)
        
        let maskLayer = CAGradientLayer()
        maskLayer.masksToBounds = true
        maskLayer.frame = artworkimage.bounds
        maskLayer.shadowRadius = 5
        maskLayer.shadowPath = CGPath(roundedRect: artworkimage.bounds.insetBy(dx: 5, dy: 5), cornerWidth: 50, cornerHeight: 50, transform: nil)
        maskLayer.shadowOpacity = 1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        artworkimage.layer.mask = maskLayer
        
        let all = UIBezierPath(roundedRect: tuner.bounds, cornerRadius: 20)
        let layer = CAShapeLayer()
        layer.masksToBounds = true
        layer.frame = tuner.bounds
        layer.path = all.cgPath
        tuner.layer.mask = layer
        
        let delegate = FrequencyDelegate()
        tunercontroller?.tableView.delegate = delegate
        tunercontroller?.tableView.dataSource = delegate
        
        playpausebutton.tintColor = UIColor.orange
        playpausebutton.animationStyle = .splitAndRotate
        
        waves.videoURL = Bundle.main.url(forResource: "waves", withExtension: "mp4")
        waves.shouldLoop = true
        
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        AVAudioSession.sharedInstance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Media.playing { waves.playVideo() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.refresh()
            swipe?.setDiagonalSwipe(enabled: true)
        }
        
        if nphelp, let vc = nphelpvc { present(vc, animated: true) }
        else if connecthelp { Alerts.connect(on: self) }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        waves.pauseVideo()
        gm?.hide(frequencies: ())
    }
    
    //MARK: - tasks
    
    @objc func escape() {
        manager?.hide(frequencies: ())
    }
    
    func refresh() {
        manager = GeneralManager(to: self)
    }
    
    //MARK: - actions
    
    @IBAction func rewind(_ sender: Any) {
        gm?.retreat()
    }
    
    @IBAction func playpause(_ sender: Any) {
        guard playpausebutton.isPaused else {
            q.manager?.pause()
            playpausebutton.setPaused(true, animated: true)
            return
        }
        
        switch q.manager?.status ?? .none {
        case .paused:
            playpausebutton.setPaused(false, animated: true)
            break
        case .streaming, .queue, .requests, .shuffle, .fill: break
        case _ where !frequencies.isEmpty: return gm?.view(frequencies: ()) ?? ()
        case .radio, .library: break
        case .none: return
        }
        
        q.manager?.play()
        q.refresh()
        refresh()
        
    }
    
    @IBAction func fastforward(_ sender: Any) {
        gm?.advance()
        q.refresh()
        refresh()
    }
    
    //MARK: - navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "options":
            guard let vc = segue.destination as? OptionsTableViewController else { return }
            profilebar.options = vc
            profilebar.optionscontainer = options
            profilebar.optionscover = optionscover
            vc.profilebar = profilebar
        case "tuner":
            guard let vc = segue.destination as? FrequencyTableViewController else { return }
            tunercontroller = vc
        default: break
        }
    }

}
