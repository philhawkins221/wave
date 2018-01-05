//
//  Global.swift
//  Clique
//
//  Created by Phil Hawkins on 1/1/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

//MARK: - properties

//let id: String = ""
//let username: String = "anonymous"
let searchlimit: Int = 25

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
}

enum Vote {
    case up
    case down
}

//MARK: - extensions

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        let size = Int(count)
        
        // empty and single-element collections don't shuffle
        if size < 2 { return }
        
        for i in 0..<(size - 1) {
            let j = Int(arc4random_uniform(UInt32(size - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
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
            let widthScale = size/(imageView?.image!.size.width)!
            let heightScale = size/(imageView?.image!.size.height)!
            imageView?.transform = CGAffineTransform(scaleX: widthScale, y: heightScale)
        }
    }
}
