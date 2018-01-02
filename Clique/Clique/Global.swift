//
//  Global.swift
//  Clique
//
//  Created by Phil Hawkins on 1/1/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

//MARK: - properties

let id: String = ""
let username: String = "anonymous"

//MARK: - enumerations

enum Catalogues: String {
    case AppleMusic = "Apple Music"
    case Spotify = "Spotify"
    case Library = "Library"
}

enum RequestMethod {
    case get
    case put
    case post
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
