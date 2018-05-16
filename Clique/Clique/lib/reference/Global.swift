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

let searchlimit: Int = 25

let player = MPMusicPlayerController.systemMusicPlayer

let scClientID = "2c9d9d500b26f5a1ae7661215c5b4e1c"
let scClientSecret = "1745f37d41a47591147470a84acda2c5"

var spotifysession: SPTSession?
var spotifyauth = SPTAuth.defaultInstance()
let kClientId = "f1cd061f0eef478d9fb478d2da3340c2"
let kCallbackURL = "clique-login://callback"
let kTokenSwapURL = "http://localhost:1234/swap"

let gracenoteClientID = "81551439-3AA3A5676BCCC908DEF78011FFDDF66E"
var gracenoteUserID: String {
    get { return UserDefaults.standard.string(forKey: "gracenote") ?? "" }
    set { UserDefaults.standard.set(newValue, forKey: "gracenote") }
}

//MARK: - root view controllers

var swipe: SwipeController?

var bro = BrowseViewController()
var np = NowPlayingViewController()
var q = QueueViewController()

//MARK: - general manager

var gm: GeneralManager? { return np.manager }

//MARK: - help view controllers

var brohelp = false
var nphelp = false
var qhelp = false

var brohelpvc = bro.storyboard?.instantiateViewController(withIdentifier: "brohelpvc")
var nphelpvc = np.storyboard?.instantiateViewController(withIdentifier: "nphelpvc")
var qhelpvc = q.storyboard?.instantiateViewController(withIdentifier: "qhelpvc")

//MARK: - type aliases

//typealias Library = [Playlist]
//typealias UserID = String

//MARK: - enumerations

enum Catalogues: String {
    case AppleMusic = "apple music"
    case Spotify = "spotify"
    case Library = "library"
    case Radio = "radio"
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

enum Option {
    case settings
    case friendRequests
    case checkFrequencies
    case shareQueue
    case shuffle
    case addSong
    case addFriend
    case removeFriend
    case addPlaylist
    case removePlaylist
    case joinQueue
    case addUser
    case playPlaylist
    case addPlaylistToLibrary
    case sharePlaylist
    case playAll
    case playCatalog
    case addCatalogToLibrary
    case addHistoryPlaylist
    
    case stopSharing
    case stopListening
    case stopViewing
    case stopSyncing
    
    case none
}

enum Setting {
    case applemusic
    case spotify
    
    case sharing
    
    case donotdisturb
    case requestsonly
    case takerequests
    
    case voting
    case radio
    case shuffle
    
    case stopSharing
    case stopListening
    
    case delete
    case none
}

enum Action {
    //playlist actions
    case viewPlaylist
    case playPlaylist
    case addToLibrary
    
    //song actions
    case nowPlaying
    case playSong
    case playSingle
    case skipToSong
    case addToLikes
    case addToPlaylist
    case upvote
    case downvote
    case addToQueue
    case addSingleToQueue
    case request
    case send
    case viewArtist
    
    //user actions
    case viewUser
    case addToFriends
    case joinQueue
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

enum QueueMode {
    case queue
    case history
    case listeners
    case requests
    case radio
}

enum SettingsMode {
    case general
    case queue
    case sharing
    case help
}

enum Requests: String {
    case friend = "friend"
    case song = "song"
}

enum Inform {
    case userNotFound
    case doNotDisturb
    case noAccount
    case stopListening
    case notFriends
    case canNotQueueSong
    case noStreaming
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

extension UIImage {
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
            indentationLevel = -4
        }
    }
    
    @objc func showRowActions(_ arg1: Bool = true) { print("ding dong") }
    
    class func show() {
        //guard self === UITableViewCell.self else { return }
        
        struct Inner {
            static let i: Void = {
                let hiddenString = String(":noitamrifnoCeteleDgniwohStes_".reversed())
                let originalSelector = NSSelectorFromString(hiddenString)
                let swizzledSelector = #selector(showRowActions(_:))
                let originalMethod = class_getInstanceMethod(UITableViewCell.self, originalSelector)
                let swizzledMethod = class_getInstanceMethod(UITableViewCell.self, swizzledSelector)
                class_addMethod(UITableViewCell.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
                print("swizzled")
            }()
        }
        
        let _ = Inner.i
    }
}

extension UITableView {
    @objc func hideRowActions(_ arg1: Bool = false) {}
    
    class func hide() {
        //guard self === UITableViewCell.self else { return }
        
        struct Inner {
            static let i: () = {
                let hiddenString = String(":eteleDdiDwoReteleDoTepiwSdne_".reversed())
                let originalSelector = NSSelectorFromString(hiddenString)
                let swizzledSelector = #selector(hideRowActions(_:))
                let originalMethod = class_getInstanceMethod(UITableView.self, originalSelector)
                let swizzledMethod = class_getInstanceMethod(UITableView.self, swizzledSelector)
                class_addMethod(UITableView.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
                print("swizzled")
            }()
        }
        
        let _ = Inner.i
    }
}
