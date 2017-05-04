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
    fileprivate static let baseRef: FIRDatabaseReference = FIRDatabase.database().reference()
    
    init() {}
}

/* Region entering/exiting */
extension Logger {
    private static var regionRef: FIRDatabaseReference {
        return baseRef.child("Regions/\(UserConfig.shared.userKey)")
    }
    
    enum regionInteraction {
        case entered
        case exited
    }
    
    static func logRegionInteraction(region: String, way: regionInteraction) {
        let logRef = self.regionRef.child(region).child("\(Int(Date().timeIntervalSince1970))")
        
        var key: String
        switch (way) {
        case .entered:
            key = "entered"
            break
        case .exited:
            key = "exited"
            break
        }
        
        logRef.setValue(key)
    }
}

// Notification interactions
extension Logger {
    private static var notificationRef: FIRDatabaseReference {
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
    static func logActionNotificationAction(for habit: String, and description: String, action: TaskInteractionAction, decline_reason: String?) {
        let ref = notificationRef.child("\(habit)").child("\(description)")
        
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
