//
//  HelpViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 5/16/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit
import RSPlayPauseButton

class HelpViewController: UIViewController {
    
    var helps = [UIView]()
    var ok: UIButton?
    var displayed = [false, false, false, false]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reveal()
    }
    
    func hide() {
        ok?.setTitle("next", for: .normal)
        for help in helps { help.alpha = 0 }
        displayed = [false, false, false, false]
    }
    
    func reveal() {
        guard displayed.contains(false) else { return dismiss(animated: true) }
        guard helps.count == displayed.count else { return }
        var i = 0
        
        for j in displayed.indices { if !displayed[j] { i = j; break } }
        let help = helps[i]
        
        UIView.animate(withDuration: 0.2, animations: { help.alpha = 1 })
        displayed[i] = true
        if !displayed.contains(false) { ok?.setTitle("ok", for: .normal) }
    }

}

class BrowseHelpViewController: HelpViewController {
    
    @IBOutlet weak var first: UILabel!
    @IBOutlet weak var second: UIView!
    @IBOutlet weak var third: UILabel!
    @IBOutlet weak var fourth: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        helps = [first, second, third, fourth]
        ok = button
        
        brohelp = false
        super.viewWillAppear(animated)
    }
    
    @IBAction func next(_ sender: Any) {
        reveal()
    }
}

class NowPlayingHelpViewController: HelpViewController {
    
    @IBOutlet weak var first: UIView!
    @IBOutlet weak var second: UIView!
    @IBOutlet weak var third: UIView!
    @IBOutlet weak var fourth: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var pp: RSPlayPauseButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pp.animationStyle = .splitAndRotate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        helps = [first, second, third, fourth]
        ok = button
        pp.isPaused = true
        
        nphelp = false
        super.viewWillAppear(animated)
    }
    
    @IBAction func tap(_ sender: Any) {
        pp.setPaused(!pp.isPaused, animated: true)
    }
    
    @IBAction func next(_ sender: Any) {
        reveal()
    }
}

class QueueHelpViewController: HelpViewController {
    
    @IBOutlet weak var first: UILabel!
    @IBOutlet weak var second: UIView!
    @IBOutlet weak var third: UIView!
    @IBOutlet weak var fourth: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        helps = [first, second, third, fourth]
        ok = button
        
        qhelp = false
        super.viewWillAppear(animated)
    }
    
    @IBAction func next(_ sender: Any) {
        reveal()
    }
}
