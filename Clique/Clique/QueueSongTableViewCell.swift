//
//  QueueSongTableViewCell.swift
//  Clique
//
//  Created by Phil Hawkins on 12/12/17.
//  Copyright © 2017 Phil Hawkins. All rights reserved.
//

import UIKit

class QueueSongTableViewCell: UITableViewCell {

    @IBOutlet weak var voteslabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(song: Song) {
        super.init(style: .subtitle, reuseIdentifier: nil)
        
        textLabel?.text = song.title
        detailTextLabel?.text = song.artist.name
        voteslabel.text = song.votes.description
        accessoryType = .none
        //artwork
        setImageSize(to: 50)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
