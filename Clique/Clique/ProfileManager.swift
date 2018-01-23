//
//  ProfileManager.swift
//  Clique
//
//  Created by Phil Hawkins on 1/20/18.
//  Copyright © 2018 Phil Hawkins. All rights reserved.
//

import Foundation

protocol ProfileManager {
    /**
     Set the wave user that will be managed by the shared instance.
     - Parameter user: The wave user to be managed.
     - Throws: Management Error - Unset Instance
     */
    static func manage(user: User) throws
    static func manage(profile: User)
}
