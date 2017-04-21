//
//  Logger.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/20/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class Logger {
    let baseRef: FIRDatabaseReference = FIRDatabase.database().reference()
    
    init() {}
}

// Region entering/exiting
extension Logger {
    var regionRef: FIRDatabaseReference {
        return baseRef.child("Regions/\(UserConfig.shared.userKey)")
    }
    
    enum regionInteraction {
        case entered
        case exited
    }
    
    func logRegionInteraction(region: UInt16, way: regionInteraction) {
        Beacons.shared.getBeaconLocation(forKey: region, handler: { location in
            let ref = self.regionRef.child("\(Int(Date().timeIntervalSince1970))")
            
            var key: String
            switch (way) {
            case .entered:
                key = "entered"
                break
            case .exited:
                key = "exited"
                break
            }
            
            ref.setValue([key: location])
        })
    }
}

// Notification interactions
extension Logger {
    var notificationRef: FIRDatabaseReference {
        return baseRef.child("Notifications/\(UserConfig.shared.userKey)")
    }
    
    enum TaskInteractionAction {
        case notificationThrown
        case notificationAccepted
        case notificationDeclinedWithReason
        case notificationDeclinedWithoutReason
        case notificationCleared
        case notificationTapped
    }
    
    /** Get Firebase ref for logging a task notification action happening now */
    func logTaskNotificationAction(_ task: Task, action: TaskInteractionAction) {
        let ref = notificationRef.child("\(task._id)/\(Int(Date().timeIntervalSince1970))")
        
        switch action {
        case .notificationThrown:
            ref.setValue("notificationThrown")
            break
        case .notificationAccepted:
            ref.setValue("notificationAccepted")
            break
        case .notificationDeclinedWithoutReason:
            ref.setValue("notificationDeclinedWithoutReason")
            break
        case .notificationDeclinedWithReason:
            ref.setValue("notificationDeclinedWithReason")
            break
        case .notificationCleared:
            ref.setValue("notificationCleared")
            break
        case .notificationTapped:
            ref.setValue("notificationTapped")
            break
        }
    }
    
    func logNotificationDeclineReason(_ task: Task, reason: String) {
        let ref = baseRef.child("DeclineReasons/\(UserConfig.shared.userKey)/\(task._id)/\(Int(Date().timeIntervalSince1970))")
        
        ref.setValue(reason)
    }
}
