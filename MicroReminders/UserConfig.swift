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
    
    let userKey: String = "delta"

    private let thresholdRef: FIRDatabaseReference
    private var renotifyThreshold: Double?  // Minimum number of minutes outside region before notification
    
    func getThreshold(handler: @escaping (Double) -> Void) {
        if (self.renotifyThreshold != nil) {
            handler(self.renotifyThreshold!)
        }
        else {
            self.thresholdRef.observeSingleEvent(of: .value, with: { snapshot in
                let thresh = snapshot.value as! Double
                self.renotifyThreshold = thresh
                
                handler(self.renotifyThreshold!)
            })
        }
    }
    
    private init() {
        let ref = FIRDatabase.database().reference()
        self.thresholdRef = ref.child("UserConfig/thresholds/\(self.userKey)")
    }
}
