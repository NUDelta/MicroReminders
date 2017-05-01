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
            "context": h_action.context,
            "habit": h_action.habit,
            "description": h_action.description
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let requestIdentifier = "reminder"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        logger.logTaskNotificationAction(h_action, action: .notificationThrown)
    }
}

/** Respond to notification actions */
extension NotificationHandler {
    /** Extract an h_action from a notification */
    fileprivate func extractTaskFromNotification(_ notification: UNNotification) -> HabitAction {
        let userInfo = notification.request.content.userInfo as! [String : Any]
        
        return HabitAction(
            userInfo["description"] as! String,
            habit: userInfo["habit"] as! String,
            context: userInfo["context"] as! Context
        )
    }
    
    /** Accept a notification from an action */
    func accept(_ notification: UNNotification) {
        let h_action = extractTaskFromNotification(notification)
        
        notificationAccept(h_action)
    }
    
    func decline(_ notification: UNNotification, reason: String?) {
        let h_action = extractTaskFromNotification(notification)
        
        notificationDecline(h_action, reason: reason)
    }
    
    /* Snooze a notification by clearing */
    func clearSnooze(_ notification: UNNotification) {
        let h_action = extractTaskFromNotification(notification)
        
        notificationClear(h_action)
    }
    
    /* Tap a notification and interact in-app */
    func tapped(_ notification: UNNotification) {
        let h_action = extractTaskFromNotification(notification)
        
        notificationTapped(h_action)
    }

}



















































