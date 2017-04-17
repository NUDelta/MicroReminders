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
    fileprivate enum TaskInteractionAction {
        case notificationThrown
        case notificationSnoozed
        case notificationDone
        case notificationCleared
        case listDone
        case listReactivated
    }
    
    fileprivate let myId = UIDevice.current.identifierForVendor!.uuidString
    
    /** Mark a task as completed from a notification */
    func markNotificationDone(_ task: Task, handler: (() -> Void)! = nil) {
        task.completed = String(Int(Date().timeIntervalSince1970))
        task.pushToFirebase(handler: handler)
        logTaskNotificationAction(task, action: .notificationDone)
    }
    
    /** Mark a task completed from the task list */
    func markListDone(_ task: Task, handler: (() -> Void)! = nil) {
        task.completed = String(Int(Date().timeIntervalSince1970))
        task.pushToFirebase(handler: handler)
        logTaskNotificationAction(task, action: .listDone)
    }
    
    /** Mark a task reactivated from the task list */
    func markListReactivated(_ task: Task, handler: (() -> Void)! = nil) {
        task.completed = "false"
        task.pushToFirebase(handler: handler)
        logTaskNotificationAction(task, action: .listReactivated)
    }
    
    /** Snooze a task */
    func notificationSnooze(_ task: Task, handler: (() -> Void)! = nil) {
        task.lastSnoozed = String(Int(Date().timeIntervalSince1970))
        task.pushToFirebase(handler: handler)
        logTaskNotificationAction(task, action: .notificationSnoozed)
    }
    
    func notificationClear(_ task: Task, handler: (() -> Void)! = nil) {
        task.lastSnoozed = String(Int(Date().timeIntervalSince1970))
        task.pushToFirebase(handler: handler)
        logTaskNotificationAction(task, action: .notificationCleared)
    }
    
    /** Get Firebase ref for logging a task notification action happening now */
    fileprivate func logTaskNotificationAction(_ task: Task, action: TaskInteractionAction) {
        let ref = FIRDatabase.database().reference().child("Notifications/\(myId)/\(task._id)/\(Int(Date().timeIntervalSince1970))")
        
        switch action {
        case .notificationThrown:
            ref.setValue("notificationThrown")
        case .notificationSnoozed:
            ref.setValue("notificationSnoozed")
        case .notificationDone:
            ref.setValue("notificationDone")
        case .notificationCleared:
            ref.setValue("notificationCleared")
        case .listDone:
            ref.setValue("listDone")
        case .listReactivated:
            ref.setValue("listReactivated")
        }
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
        
        logTaskNotificationAction(task, action: .notificationThrown)
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
    func notify(_ location: String) {
        
        Tasks.getTasks(then: {tasks in
            let candidatesForNotification = tasks.filter({ self.canNotify(for: $0, location: location) })
            
            if (!candidatesForNotification.isEmpty) {
                let taskToNotify = self.scheduler.pickTaskToNotify(tasks: candidatesForNotification)
                self.sendNotification(taskToNotify)
            }
        })
    }
}

/** Respond to a task notification */
class TaskNotificationResponder: TaskInteractionManager {
    
    /** Extract a a task from a notification */
    func extractTaskFromNotification(_ notification: UNNotification) -> Task {
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
    
    /** Mark a task as completed */
    func markDone(_ notification: UNNotification) {
        let task = extractTaskFromNotification(notification)
        markNotificationDone(task)
    }
    
    /** Snooze a task */
    func snooze(_ notification: UNNotification) {
        let task = extractTaskFromNotification(notification)
        notificationSnooze(task)
    }
    
    func clearSnooze(_ notification: UNNotification) {
        let task = extractTaskFromNotification(notification)
        notificationClear(task)
    }
}


/** Pick the next task to notify */
fileprivate class TaskScheduler {
    
    /** Pick a random task */
    func pickRandom(tasks: [Task]) -> Task {
        let randomInd = Int(arc4random()) % tasks.count
        return tasks[randomInd]
    }
    
    /** Pick a scheduling policy, and notify for that task */
    func pickTaskToNotify(tasks: [Task]) -> Task {
        return pickRandom(tasks: tasks)
    }
    
    func pickTaskToChainNotify(tasks: [Task]) -> Task {
        return pickRandom(tasks: tasks)
    }
}










