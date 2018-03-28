//
//  QueueHeaderTableViewCell.swift
//  Clique
//
//  Created by Phil Hawkins on 3/27/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit

class QueueHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var editlabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
