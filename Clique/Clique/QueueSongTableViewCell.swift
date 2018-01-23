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
        let url = URL(string: song.artwork) ?? URL(string: "/")!
        setImageSize(to: 50)
        imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "genericart.png"))
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

class NowPlayingTableViewCell: UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(song: Song?) {
        super.init(style: .subtitle, reuseIdentifier: nil)
        
        if let song = song {
            textLabel?.text = song.title
            detailTextLabel?.text = song.artist.name
            textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
            accessoryType = .none
            let url = URL(string: song.artwork) ?? URL(string: "/")!
            imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "genericart.png"))
            setImageSize(to: 100)
        } else {
            imageView?.image = UIImage(named: "genericart.png")
            setImageSize(to: 100)
            accessoryType = .none
        }
    }
}
