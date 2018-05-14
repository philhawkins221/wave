//
//  ActionsDelegate.swift
//  Clique
//
//  Created by Phil Hawkins on 5/12/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

class ActionsDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - properties
    
    let actions: [Action]
    
    var playlist: Playlist? { return Actions.playlist }
    var song: Song? { return Actions.song }
    var user: User? { return Actions.user }
    
    //MARK: - initializers
    
    init(actions: [Action]) {
        self.actions = actions
    }
    
    //MARK: - table delegate stack
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Actions.execute(actions[indexPath.row])
    }
    
    //MARK: - table data source stack
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        switch actions[indexPath.row] {
        case .viewPlaylist:
            cell.textLabel?.text = "view playlist"
            return cell
        case .playPlaylist:
            cell.textLabel?.text = "play"
            return cell
        case .addToLibrary:
            cell.textLabel?.text = "add playlist to library"
            return cell
        case .playSong:
            cell.textLabel?.text = "play"
            return cell
        case .skipToSong:
            cell.textLabel?.text = "play"
            cell.detailTextLabel?.text = "earlier songs will be skipped"
            return cell
        case .addToLikes:
            cell.textLabel?.text = "add to likes"
            return cell
        case .addToPlaylist:
            cell.textLabel?.text = "add to a playlist"
            cell.accessoryType = .disclosureIndicator
            return cell
        case .upvote:
            cell.textLabel?.text = "+ upvote"
            return cell
        case .downvote:
            cell.textLabel?.text = "- downvote"
            return cell
        case .addToQueue:
            cell.textLabel?.text = "add to queue"
            return cell
        case .request:
            cell.textLabel?.text = "request"
            return cell
        case .send:
            cell.textLabel?.text = "send"
            cell.detailTextLabel?.text = "add to a friend's queue"
            cell.accessoryType = .disclosureIndicator
            return cell
        case .viewArtist:
            guard let song = song else { return cell }
            cell.textLabel?.text = "view " + song.artist.name
            cell.detailTextLabel?.text = "browse top songs and albums"
            return cell
        case .viewUser:
            cell.textLabel?.text = "view library"
            cell.detailTextLabel?.text = "browse songs and playlists"
            return cell
        case .addToFriends:
            guard let user = user else { return cell }
            cell.textLabel?.text = "add friend"
            cell.detailTextLabel?.text = "send @" + user.username + " a friend request"
            return cell
        case .joinQueue:
            guard let user = user else { return cell }
            let listening = !user.me() && user == q.manager?.client()
            let dnd = user.queue.donotdisturb
            cell.textLabel?.text = listening ? "leave queue" : "join queue"
            cell.detailTextLabel?.text = dnd ? "do not disturb enabled" : listening ? " stop listening with @" + user.username : "listen with @" + user.username
            return cell
        }
    }
    
}
