//
//  Global.swift
//  Clique
//
//  Created by Phil Hawkins on 1/1/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation
import MediaPlayer

//MARK: - properties

//let id: String = ""
//let username: String = "anonymous"
let searchlimit: Int = 25

let player = MPMusicPlayerController.systemMusicPlayer

let scClientID = "2c9d9d500b26f5a1ae7661215c5b4e1c"
let scClientSecret = "1745f37d41a47591147470a84acda2c5"

//MARK: - base view controllers

var bro = BrowseViewController()
var np = NowPlayingViewController()
var q = QueueViewController()

//MARK: - enumerations

enum Catalogues: String {
    case AppleMusic = "apple music"
    case Spotify = "spotify"
    case Library = "library"
}

enum RequestMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum Vote {
    case up
    case down
}

enum VCid: String {
    case bro = "bro"
    case np = "np"
    case q = "q"
    
    case broNav = "bronav"
    case allSongs = "allsongs"
}

enum ProfileController {
    case browse
    case nowplaying
    case queue
}

enum BrowseMode: String {
    case browse
    case friends
    case library
    case playlist
    case sync
    case search
    case catalog
}

enum SearchMode {
    case none
    case users
    case applemusic
    case spotify
    case library
}

enum Sorting {
    case song
    case artist
}

//MARK: - errors

enum ControllerError: String, Error {
    case wrongProvisioning = "Controller Error - Wrong Provisioning"
}

enum ManagementError: String, Error {
    case unsetInstance = "Management Error - Unset Instance"
    case unidentifiedUser = "Management Error - Unidentified User"
}

//MARK: - extensions

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffled() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        let size = Int(count)
        
        // empty and single-element collections don't shuffle
        if size < 2 { return }
        
        for i in 0..<(size - 1) {
            let j = Int(arc4random_uniform(UInt32(size - i))) + i
            guard i != j else { continue }
            self.swapAt(i, j)
        }
    }
}

extension String {
    public func addingFormEncoding() -> String? {
        var allowed = NSMutableCharacterSet.alphanumeric() as CharacterSet
        
        let unreserved = "*-._"
        allowed.insert(charactersIn: unreserved)
        
        allowed.insert(charactersIn: " ")
        var encoded = addingPercentEncoding(withAllowedCharacters: allowed)
        encoded = encoded?.replacingOccurrences(of: " ", with: "+")
        
        return encoded
    }
}

extension UITableViewCell {
    func setImageSize(to size: CGFloat) {
        if imageView?.image != nil {
            let itemSize = CGSize.init(width: size, height: size)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            imageView?.image!.draw(in: imageRect)
            imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
    }
}
