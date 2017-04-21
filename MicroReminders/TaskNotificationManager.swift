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
    
    fileprivate func sendNotification(_ task: Task, subtitle: String? = nil, message: String? = nil, delay: Double? = nil) {
        print("Notifying \(task.name)")
        
        let content = UNMutableNotificationContent()
        content.title = task.name
        if subtitle != nil { content.subtitle = subtitle! }
        content.body = message == nil ? "Reminder to \(task.name.lowercased())!" : message!
        if message != nil { content.body = message! }
        
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "respond_to_task"
        content.userInfo = userInfoFromTask(task)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay != nil ? delay! : 0.1, repeats: false)
        
        let requestIdentifier = "reminder"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        logger.logTaskNotificationAction(task, action: .notificationThrown)
    }
    
    private func secondsIntoDay() -> Float {
        let cal = Calendar.current
        
        return Float(Date().timeIntervalSince(cal.startOfDay(for: Date())))
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










