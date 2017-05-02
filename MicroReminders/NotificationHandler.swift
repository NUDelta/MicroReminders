//
//  NotificationHandler.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/28/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import UserNotifications

/** Handles sending reminders. */
class NotificationHandler {
    init() {}
}

/** Send an action notification */
extension NotificationHandler {
    
    func sendNotificationNow(_ h_action: HabitAction) {
        print("Notifying \(h_action.description)")
        
        let content = UNMutableNotificationContent()
        content.title = h_action.description
        content.subtitle = ""
        content.body = "Reminder to \(h_action.description.lowercased())!"
        
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "action_notification"
        
        content.userInfo = [
            "habit": h_action.habit,
            "description": h_action.description
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let requestIdentifier = "reminder"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        Logger.logActionNotificationAction(for: h_action.habit, and: h_action.description, action: .thrown, decline_reason: nil)
        HabitAction.setLastInteraction(of: .thrown,
                                       withHabit: h_action.habit,
                                       withAction: h_action.description,
                                       to: Int(Date().timeIntervalSince1970),
                                       with: nil)
    }
    
}

/** Respond to notification actions */
extension NotificationHandler {
    /** Extract an h_action from a notification */
    fileprivate func extractHabitAction(from notification: UNNotification) -> (String, String) {
        let userInfo = notification.request.content.userInfo as! [String : Any]
        
        return (userInfo["habit"] as! String, userInfo["description"] as! String)
    }
    
    func accept(_ notification: UNNotification) {
        let (habit, description) = extractHabitAction(from: notification)
        
        Logger.logActionNotificationAction(for: habit, and: description, action: .acceptedInNotification, decline_reason: nil)
        
        HabitAction.setLastInteraction(of: .accepted,
                                       withHabit: habit,
                                       withAction: description,
                                       to: Int(Date().timeIntervalSince1970),
                                       with: nil)
    }
    
    func decline(_ notification: UNNotification, reason: String?) {
        let (habit, description) = extractHabitAction(from: notification)
        
        Logger.logActionNotificationAction(for: habit, and: description,
                                           action: (reason != nil) ? .declinedWithReasonInNotification : .declinedInNotification,
                                           decline_reason: reason)
        
        HabitAction.setLastInteraction(of: .declined,
                                       withHabit: habit,
                                       withAction: description,
                                       to: Int(Date().timeIntervalSince1970),
                                       with: nil)
    }
    
    func clear(_ notification: UNNotification) {
        let (habit, description) = extractHabitAction(from: notification)
        
        Logger.logActionNotificationAction(for: habit, and: description, action: .cleared, decline_reason: nil)
        
        HabitAction.setLastInteraction(of: .declined,
                                       withHabit: habit,
                                       withAction: description,
                                       to: Int(Date().timeIntervalSince1970),
                                       with: nil)
    }
}



















































