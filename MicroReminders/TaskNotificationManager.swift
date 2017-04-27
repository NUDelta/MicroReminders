//
//  Notify.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/28/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class TaskInteractionManager {
    
    fileprivate let myId = UserConfig.shared.userKey
    fileprivate let logger = Logger()
    
    /** Accept an h_action */
    fileprivate func notificationAccept(_ h_action: HabitAction) {
        h_action.lastSnoozed = String(Int(Date().timeIntervalSince1970)) // This is probably not useful, needs new field
        h_action.pushToFirebase(handler: nil)
        logger.logTaskNotificationAction(h_action, action: .notificationAccepted)
    }
    
    fileprivate func notificationDecline(_ h_action: HabitAction, reason: String?) {
        h_action.lastSnoozed = String(Int(Date().timeIntervalSince1970)) // Also probably not useful
        h_action.pushToFirebase(handler: nil)
        
        if (reason != nil) {
            logger.logTaskNotificationAction(h_action, action: .notificationDeclinedWithReason)
            logger.logNotificationDeclineReason(h_action, reason: reason!)
        }
        else {
            logger.logTaskNotificationAction(h_action, action: .notificationDeclinedWithoutReason)
        }
    }
    
    /** Snooze by tapping or clearing */
    fileprivate func notificationClear(_ h_action: HabitAction) {
        h_action.lastSnoozed = String(Int(Date().timeIntervalSince1970))
        h_action.pushToFirebase(handler: nil)
        logger.logTaskNotificationAction(h_action, action: .notificationCleared)
    }
    
    fileprivate func notificationTapped(_ h_action: HabitAction) {
        h_action.lastSnoozed = String(Int(Date().timeIntervalSince1970))
        h_action.pushToFirebase(handler: nil)
        logger.logTaskNotificationAction(h_action, action: .notificationTapped)
    }
}

/** Send h_action notifications */
class TaskNotificationSender: TaskInteractionManager {
    fileprivate let scheduler = TaskScheduler()
    
    /** Convert an h_action to a dictionary for storage in a notification */
    fileprivate func userInfoFromTask(_ h_action: HabitAction) -> [String: String] {
        return [
            "t_id":h_action._id,
            "t_name":h_action.name,
            "t_completed":h_action.completed,
            "t_length":h_action.length,
            "t_lastSnoozed":h_action.lastSnoozed,
            "t_created":h_action.created,
            "t_location":h_action.location,
            "t_beforeTime":h_action.beforeTime,
            "t_afterTime":h_action.afterTime
        ]
    }
    
    fileprivate func sendNotification(_ h_action: HabitAction, subtitle: String? = nil, message: String? = nil, delay: Double? = nil) {
        print("Notifying \(h_action.name)")
        
        let content = UNMutableNotificationContent()
        content.title = h_action.name
        if subtitle != nil { content.subtitle = subtitle! }
        content.body = message == nil ? "Reminder to \(h_action.name.lowercased())!" : message!
        if message != nil { content.body = message! }
        
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "respond_to_task"
        content.userInfo = userInfoFromTask(h_action)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay != nil ? delay! : 0.1, repeats: false)
        
        let requestIdentifier = "reminder"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        logger.logTaskNotificationAction(h_action, action: .notificationThrown)
    }
    
    private func secondsIntoDay() -> Float {
        let cal = Calendar.current
        
        let twoAM = Float(2 * 60 * 60)
        let twentyFourHours = Float(24 * 60 * 60)
        
        let seconds = Float(Date().timeIntervalSince(cal.startOfDay(for: Date())))
        
        return seconds < twoAM ? seconds + twentyFourHours : seconds
    }
    
    /** Determines if the h_action can be notified for now. Checks location and time constraints. */
    private func canNotify(for h_action: HabitAction, location: String) -> Bool {
        let seconds = secondsIntoDay()
        
        return {
            h_action.completed == "false" &&
            h_action.location.caseInsensitiveCompare(location) == .orderedSame &&
            Float(h_action.beforeTime)! > seconds &&
            Float(h_action.afterTime)! < seconds
            }()
    }
    
    /** Select and notify for tasks for a given location, at the current time */
    fileprivate func notify(_ location: String) {

        /*
        Habits.getHabits(then: {tasks in
            let candidatesForNotification = tasks.filter({ self.canNotify(for: $0, location: location) })
            
            if (!candidatesForNotification.isEmpty) {
                let taskToNotify = self.scheduler.pickTaskToNotify(tasks: candidatesForNotification)
                self.sendNotification(taskToNotify)
            }
        })
        */
    }
    
    /** Handle entering region */
    func entered(region regionInt: UInt16) {
        Beacons.shared.getBeaconLocation(forKey: regionInt, handler: { location in
            Beacons.shared.getExitTime(forKey: regionInt, handler: { then in
                UserConfig.shared.getThreshold(handler: { threshold in
                    /*
                     This should never be relevant - we should only ever enter after exiting. What that means
                     is that we should check this value before it is set here, and set it again in "exited"
                     before we check it next. However, since the beacons are buggy, and I'm concerned about
                     sequential "entered" events, I'm leaving this in here.
                     */
                    Beacons.shared.setExitTime(forKey: regionInt, to: Date(timeIntervalSinceNow: Double(Int.max)))
                    
                    if (Date().timeIntervalSince(then) > 60.0*threshold) {
                        self.notify(location)
                    }
                })
            })
        })
    }
    
    /** Handle exiting region */
    func exited(region regionInt: UInt16) {
        Beacons.shared.getExitTime(forKey: regionInt, handler: { then in
            /*
             This is to ensure that we only reset the exit time if the previous region event was an
             entrance, protecting against sequential exit events.
             */
            if (then.timeIntervalSinceNow > Double(Int.max/2)) {
                Beacons.shared.setExitTime(forKey: regionInt, to: Date())
            }
        })
    }
    
}

/** Respond to an h_action notification */
class TaskNotificationResponder: TaskInteractionManager {
    
    /** Extract an h_action from a notification */
    fileprivate func extractTaskFromNotification(_ notification: UNNotification) -> HabitAction {
        let userInfo = notification.request.content.userInfo as! [String:String]
        
        return HabitAction(
            userInfo["t_id"]!,
            name: userInfo["t_name"]!,
            location: userInfo["t_location"]!,
            beforeTime: userInfo["t_beforeTime"]!,
            afterTime: userInfo["t_afterTime"]!,
            completed: userInfo["t_completed"]!,
            lastSnoozed: userInfo["t_lastSnoozed"]!
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


/** Pick the next h_action to notify */
fileprivate class TaskScheduler {
    
    /** Pick a random h_action */
    fileprivate func pickRandom(tasks: [HabitAction]) -> HabitAction {
        let randomInd = Int(arc4random()) % tasks.count
        return tasks[randomInd]
    }
    
    /** Pick a scheduling policy, and notify for that h_action */
    fileprivate func pickTaskToNotify(tasks: [HabitAction]) -> HabitAction {
        return pickRandom(tasks: tasks)
    }
}










