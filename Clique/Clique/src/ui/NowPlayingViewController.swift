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
    
    //MARK: - lifecycle stack
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TabBarControllerStyleGuide.enforce(on: tabBarController)
        
        playpausebutton.tintColor = UIColor.orange
        playpausebutton.animationStyle = .split
        
        waves.videoURL = Bundle.main.url(forResource: "waves", withExtension: "mp4")
        waves.shouldLoop = true
        
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        waves.playVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manager?.update()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - helper methods
    
    //MARK: - storyboard actions
    
    @IBAction func rewind(_ sender: Any) {
    }
    
    @IBAction func playpause(_ sender: Any) {
        playpausebutton?.setPaused(!(playpausebutton?.isPaused ?? true), animated: true)
    }
    
    @IBAction func fastforward(_ sender: Any) {
    }
    
    //MARK: - navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }

}
