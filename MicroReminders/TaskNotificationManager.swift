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
    
    /** Accept a task */
    fileprivate func notificationAccept(_ task: Task) {
        task.lastSnoozed = String(Int(Date().timeIntervalSince1970)) // This is probably not useful, needs new field
        task.pushToFirebase(handler: nil)
        logger.logTaskNotificationAction(task, action: .notificationAccepted)
    }
    
    fileprivate func notificationDecline(_ task: Task, reason: String?) {
        task.lastSnoozed = String(Int(Date().timeIntervalSince1970)) // Also probably not useful
        task.pushToFirebase(handler: nil)
        
        if (reason != nil) {
            logger.logTaskNotificationAction(task, action: .notificationDeclinedWithReason)
            logger.logNotificationDeclineReason(task, reason: reason!)
        }
        else {
            logger.logTaskNotificationAction(task, action: .notificationDeclinedWithoutReason)
        }
    }
    
    /** Snooze by tapping or clearing */
    fileprivate func notificationClear(_ task: Task) {
        task.lastSnoozed = String(Int(Date().timeIntervalSince1970))
        task.pushToFirebase(handler: nil)
        logger.logTaskNotificationAction(task, action: .notificationCleared)
    }
    
    fileprivate func notificationTapped(_ task: Task) {
        task.lastSnoozed = String(Int(Date().timeIntervalSince1970))
        task.pushToFirebase(handler: nil)
        logger.logTaskNotificationAction(task, action: .notificationTapped)
    }
}

/** Send task notifications */
class TaskNotificationSender: TaskInteractionManager {
    fileprivate let scheduler = TaskScheduler()
    
    /** Convert a task to a dictionary for storage in a notification */
    fileprivate func userInfoFromTask(_ task: Task) -> [String: String] {
        return [
            "t_id":task._id,
            "t_name":task.name,
            "t_completed":task.completed,
            "t_length":task.length,
            "t_lastSnoozed":task.lastSnoozed,
            "t_created":task.created,
            "t_location":task.location,
            "t_beforeTime":task.beforeTime,
            "t_afterTime":task.afterTime
        ]
    }
    
    fileprivate func sendNotification(_ task: Task) {
        print("Notifying \(task.name)")
        
        let content = UNMutableNotificationContent()
        content.title = task.name
        content.body = "Reminder to \(task.name.lowercased())!"
        
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "respond_to_task"
        content.userInfo = userInfoFromTask(task)
        
        let requestIdentifier = "reminder"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        logger.logTaskNotificationAction(task, action: .notificationThrown)
    }
    
    private func secondsIntoDay() -> Float {
        let cal = Calendar.current
        
        let twoAM = Float(2 * 60 * 60)
        let twentyFourHours = Float(24 * 60 * 60)
        
        let seconds = Float(Date().timeIntervalSince(cal.startOfDay(for: Date())))
        
        return seconds < twoAM ? seconds + twentyFourHours : seconds
    }
    
    /** Determines if the task can be notified for now. Checks location and time constraints. */
    private func canNotify(for task: Task, location: String) -> Bool {
        let seconds = secondsIntoDay()
        
        return {
            task.completed == "false" &&
            task.location.caseInsensitiveCompare(location) == .orderedSame &&
            Float(task.beforeTime)! > seconds &&
            Float(task.afterTime)! < seconds
            }()
    }
    
    /** Select and notify for tasks for a given location, at the current time */
    fileprivate func notify(_ location: String) {
        Tasks.getTasks(then: {tasks in
            let candidatesForNotification = tasks.filter({ self.canNotify(for: $0, location: location) })
            
            if (!candidatesForNotification.isEmpty) {
                let taskToNotify = self.scheduler.pickTaskToNotify(tasks: candidatesForNotification)
                self.sendNotification(taskToNotify)
            }
        })
    }
    
    fileprivate func doNotNotify(for region: UInt16, howLong: Double?) {
        UserConfig.shared.getThreshold(handler: { threshold in
            // Nuke any existing notification requests
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(region)"])
            
            // Add a fresh one
            let content = UNMutableNotificationContent()
            content.title = "Do not notify for region \(region)"
            content.subtitle = "Do we need both of these?"
            content.body = "I really hope not."
            
            content.categoryIdentifier = "do_not_notify"
            content.badge = 4
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: howLong != nil ? howLong! : threshold * 60,
                repeats: false
            )
            
            let requestIdentifier = "\(region)"
            
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        })
    }
    
    /** Handle entering region */
    func entered(region regionInt: UInt16) {
        logger.logRegionInteraction(region: regionInt, way: .entered)
        
        Beacons.shared.getBeaconLocation(forKey: regionInt, handler: { location in
            Beacons.shared.okayToNotify(for: regionInt, handler: { ok in
                if ok {
                    self.notify(location)
                }
                self.doNotNotify(for: regionInt, howLong: Double(Int.max))
            })
        })
    }
    
    /** Handle exiting region */
    func exited(region regionInt: UInt16) {
        logger.logRegionInteraction(region: regionInt, way: .exited)
        
        doNotNotify(for: regionInt, howLong: nil)
    }
    
}

/** Respond to a task notification */
class TaskNotificationResponder: TaskInteractionManager {
    
    /** Extract a a task from a notification */
    fileprivate func extractTaskFromNotification(_ notification: UNNotification) -> Task {
        let userInfo = notification.request.content.userInfo as! [String:String]
        
        return Task(
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
        let task = extractTaskFromNotification(notification)
        notificationAccept(task)
    }
    
    func decline(_ notification: UNNotification, reason: String?) {
        let task = extractTaskFromNotification(notification)
        
        notificationDecline(task, reason: reason)
    }
    
    /* Snooze a notification by clearing */
    func clearSnooze(_ notification: UNNotification) {
        let task = extractTaskFromNotification(notification)
        notificationClear(task)
    }
    
    /* Tap a notification and interact in-app */
    func tapped(_ notification: UNNotification) {
        let task = extractTaskFromNotification(notification)
        notificationTapped(task)
    }
}


/** Pick the next task to notify */
fileprivate class TaskScheduler {
    
    /** Pick a random task */
    fileprivate func pickRandom(tasks: [Task]) -> Task {
        let randomInd = Int(arc4random()) % tasks.count
        return tasks[randomInd]
    }
    
    /** Pick a scheduling policy, and notify for that task */
    fileprivate func pickTaskToNotify(tasks: [Task]) -> Task {
        return pickRandom(tasks: tasks)
    }
}










