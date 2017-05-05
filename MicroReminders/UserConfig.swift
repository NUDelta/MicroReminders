//
//  Users.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/18/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class UserConfig {
    static let shared: UserConfig = UserConfig()
    
    let userKey: String = "yk"
    
    private init() {}
}
