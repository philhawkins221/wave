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
        
        //usernamelabel.contentVerticalAlignment = .bottom
    }
    
    @IBAction func usernametap(_ sender: Any) {
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
