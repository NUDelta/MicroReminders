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
            let ref = self.regionRef.child(location).child("\(Int(Date().timeIntervalSince1970))")
            
            var key: String
            switch (way) {
            case .entered:
                key = "entered"
                break
            case .exited:
                key = "exited"
                break
            }
            
            ref.setValue(key)
        })
    }
}

// Notification interactions
extension Logger {
    var notificationRef: FIRDatabaseReference {
        return baseRef.child("Notifications/\(UserConfig.shared.userKey)")
    }
    
    enum TaskInteractionAction {
        case thrown
        case acceptedInApp
        case acceptedInNotification
        case cleared
        case declinedInNotification
        case declinedWithReasonInApp
        case declinedWithReasonInNotification
    }
    
    /** Get Firebase ref for logging an h_action notification action happening now */
    func logTaskNotificationAction(_ h_action: HabitAction, action: TaskInteractionAction, decline_reason: String?) {
        let ref = notificationRef.child("\(UserConfig.shared.userKey)").child("\(h_action.habit)").child("\(h_action.description)")
        
        //.child("\(Int(Date().timeIntervalSince1970))")
        
        var value: Any // Will be a String or [String: String]
        var child: FIRDatabaseReference
        switch action {
        case .thrown:
            child = ref.child("Thrown")
            value = "thrown"
            break
        case .acceptedInApp:
            child = ref.child("Accepted")
            value = "accepted_in_app"
            break
        case .acceptedInNotification:
            child = ref.child("Accepted")
            value = "accepted_in_notification"
            break
        case .cleared:
            child = ref.child("Declined")
            value = "cleared"
            break
        case .declinedInNotification:
            child = ref.child("Declined")
            value = "declined_in_notification"
            break
        case .declinedWithReasonInNotification:
            child = ref.child("Declined")
            value = ["declined_with_reason_in_notification": decline_reason!]
            break
        case .declinedWithReasonInApp:
            child = ref.child("Declined")
            value = ["declined_with_reason_in_app": decline_reason!]
            break
        }
        child.child("\(Int(Date().timeIntervalSince1970))").setValue(value)
    }
}
