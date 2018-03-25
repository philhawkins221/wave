//
//  NowPlayingTableViewCell.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import UIKit

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
            
            if song.library == Catalogues.Library.rawValue {
                imageView?.image = Media.get(artwork: song.id) ?? UIImage(named: "genericart.png")
            } else {
                let url = URL(string: song.artwork) ?? URL(string: "/")!
                imageView?.af_setImage(withURL: url, placeholderImage: UIImage(named: "genericart.png"))
            }
            
            setImageSize(to: 100)
        } else {
            imageView?.image = UIImage(named: "genericart.png")
            setImageSize(to: 100)
            accessoryType = .none
        }
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}
