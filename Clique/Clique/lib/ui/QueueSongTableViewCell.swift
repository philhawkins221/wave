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
    
    func set(song: Song, voting: Bool = false, credit: Bool = false) {
        
        var sender: User? = nil
        if credit && song.sender != "" && song.sender != Identity.me { sender = CliqueAPI.find(user: song.sender) }
            
        textLabel?.text = song.title
        detailTextLabel?.text = sender == nil ? song.artist.name : "from: @" + sender!.username
        detailTextLabel?.textColor = sender == nil ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        voteslabel.text = voting ? song.votes.description : nil
        accessoryType = .none
        
        if song.library == Catalogues.Library.rawValue {
            imageView?.image = Media.get(artwork: song.id) ?? UIImage(named: "genericart.png")
        } else {
            let url = URL(string: song.artwork) ?? URL(string: "/")!
            imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "genericart.png"))
        }
        
        setImageSize(to: 45)
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
