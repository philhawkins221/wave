//
//  SettingsTableViewCell.swift
//  Clique
//
//  Created by Phil Hawkins on 3/28/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    //MARK: - outlets
    
    @IBOutlet weak var slider: UISwitch!
    
    //MARK: - properties
    
    var delegate: SettingsDelegate?
    
}
