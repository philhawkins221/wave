//
//  Artist.swift
//  Clique
//
//  Created by Phil Hawkins on 3/7/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

struct Artist: Codable, CatalogItem, LibraryItem {
    let id: String
    let library: String
    let name: String
}
