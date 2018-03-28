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
    
    @IBOutlet weak var artworkimage: UIImageView!
    @IBOutlet weak var songlabel: UILabel!
    @IBOutlet weak var artistlabel: UILabel!
    @IBOutlet weak var albumlabel: UILabel!
    
    @IBOutlet weak var buttonsview: UIView!
    @IBOutlet weak var rewindbutton: UIButton!
    @IBOutlet weak var playpausebutton: RSPlayPauseButton!
    @IBOutlet weak var fastforwardbutton: UIButton!
    
    //MARK: - properties
    
    var manager: GeneralManager?
    
    var frequencies = [User]()
    
    //MARK: - lifecycle stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = GeneralManager(to: self)
        profilebar.controller = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        playpausebutton.tintColor = UIColor.orange
        playpausebutton.animationStyle = .split
        
        waves.videoURL = Bundle.main.url(forResource: "waves", withExtension: "mp4")
        waves.shouldLoop = true
        
        //let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: .mixWithOthers)
        waves.playVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
        
        swipe?.setDiagonalSwipe(enabled: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tasks
    
    func refresh() {
        manager = GeneralManager(to: self)
    }
    
    //MARK: - actions
    
    @IBAction func rewind(_ sender: Any) {
    }
    
    @IBAction func playpause(_ sender: Any) {
        playpausebutton?.setPaused(!(playpausebutton?.isPaused ?? true), animated: true)
        
        return playpausebutton.isPaused ? Media.pause() : Media.play()
    }
    
    @IBAction func fastforward(_ sender: Any) {
    }
    
    //MARK: - navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "options":
            guard let vc = segue.destination as? OptionsTableViewController else { return }
            print("NowPlayingViewController preparing for options segue")
            profilebar.options = vc
            profilebar.optionscontainer = options
            profilebar.optionscover = optionscover
            vc.profilebar = profilebar
        default: break
        }
    }

}
