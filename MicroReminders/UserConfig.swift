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
    
    static let userKey = "delta"

    private let thresholdRef: FIRDatabaseReference
    private var renotifyThreshold: Double?  // Minimum number of minutes outside region before notification
    
    static func getThreshold(handler: @escaping (Double) -> Void) {
        if (shared.renotifyThreshold != nil) {
            handler(shared.renotifyThreshold!)
        }
        else {
            shared.thresholdRef.observeSingleEvent(of: .value, with: { snapshot in
                let thresh = snapshot.value as! Double
                shared.renotifyThreshold = thresh
                
                handler(shared.renotifyThreshold!)
            })
        }
    }
    
    private init() {
        self.thresholdRef = FIRDatabase().reference().child("UserConfig/thresholds/\(UserConfig.userKey)")
    }
}
