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
    
    func set(song: Song, voting: Bool = false, credit: Bool = false, artwork: Bool = false) {
        
        var sender = credit ? q.listeners[song.sender] : nil
        if credit && sender == nil && song.sender != Identity.me && song.sender != "" {
            sender = CliqueAPI.find(user: song.sender)?.username
            if sender != nil { q.listeners[song.sender] = sender }
        }
            
        textLabel?.text = song.title
        detailTextLabel?.text = sender == nil ? song.artist.name : "from: @" + sender!
        detailTextLabel?.textColor = sender == nil ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        voteslabel.text = voting ? song.votes.description : nil
        voteslabel.alpha = voting ? 0.9 : 0
        accessoryType = .none
        
        let url = URL(string: song.artwork) ?? URL(string: "/")!
        
        if artwork { imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "songpic.png")) }
        else { imageView?.image = UIImage(named: "songpic.png") }
        
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
