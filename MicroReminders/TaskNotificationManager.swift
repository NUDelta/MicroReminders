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
        }
    }
    
    /** Get Firebase ref for my tasks */
    fileprivate func firebaseRefForMyTasks() -> FIRDatabaseReference {
        return FIRDatabase.database().reference().child("Tasks/\(myId)")
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
            "t_category":task.category,
            "t_subcategory":task.subcategory,
            "t_completed":task.completed,
            "t_length":task.length,
            "t_location":task.location,
            "t_lastSnoozed":task.lastSnoozed,
            "t_created":task.created
        ]
    }
    
    fileprivate func sendNotification(_ task: Task) {
        print("Notifying \(task.name)")
        let content = UNMutableNotificationContent()
        content.title = "Reminder!"
        content.body = "\(task.name)"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "respond_to_task"
        
        content.userInfo = userInfoFromTask(task)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let requestIdentifier = "reminder"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        logTaskNotificationAction(task, action: .notificationThrown)
    }
    
    /** Select and notify for tasks for a given location */
    func notify(_ location: String) {
        let myTasksRef = firebaseRefForMyTasks()
        
        myTasksRef
            .observeSingleEvent(of: .value, with: { snapshot in
                let tasksJSON = snapshot.value as? [String: [String: String]]
                
                if (tasksJSON != nil) {
                    var candidatesForNotification = tasksJSON!
                    for (_id, taskData) in candidatesForNotification {
                        if (taskData["completed"] != "false" ||
                            taskData["location"] != location)
                        {
                                candidatesForNotification.removeValue(forKey: _id)
                        }
                    }
                    
                    if (!candidatesForNotification.isEmpty) {
                        let taskToNotify = self.scheduler.pickTaskToNotify(tasksJSON: candidatesForNotification)
                        self.sendNotification(taskToNotify)
                    }
                }
            })
    }
}

/** Respond to a task notification */
class TaskNotificationResponder: TaskInteractionManager {
    
    /** Extract a a task from a notification */
    func extractTaskFromNotification(_ notification: UNNotification) -> Task {
        let userInfo = notification.request.content.userInfo
        
        return Task(
            userInfo["t_id"] as! String,
            name: userInfo["t_name"] as! String,
            category: userInfo["t_category"] as! String,
            subcategory: userInfo["t_subcategory"] as! String,
            location: userInfo["t_location"] as! String,
            completed: userInfo["t_completed"] as! String,
            lastSnoozed: userInfo["t_lastSnoozed"] as! String
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
    
    /** Build a task from a dictionary entry from Firebase */
    func dictToTask(_id: String, taskJSON: [String: String]) -> Task {
        return Task(
            _id,
            name: taskJSON["task"]!,
            category: taskJSON["category"]!,
            subcategory: taskJSON["subcategory"]!,
            location: taskJSON["location"]!,
            completed: taskJSON["completed"]!,
            lastSnoozed: taskJSON["lastSnoozed"]!
        )
    }
    
    /** Pick the oldest (last snoozed/created) task to notify (FIFO) */
    func pickLastSnoozed(tasksJSON: [String: [String: String]]) -> Task {
        let sortedByAge = tasksJSON.sorted(by: { (task1: (_id: String, data: [String: String]), task2: (_id: String, data: [String: String])) in
            Int(task1.data["lastSnoozed"]!)! < Int(task2.data["lastSnoozed"]!)!
        })
        let oldest = sortedByAge.first!
        return dictToTask(_id: oldest.key, taskJSON: oldest.value)
    }
    
    /** Pick a random task */
    func pickRandom(tasksJSON: [String: [String: String]]) -> Task {
        let randomInd = Int(arc4random()) % tasksJSON.keys.count
        let randomKey = Array(tasksJSON.keys)[randomInd]
        return dictToTask(_id: randomKey, taskJSON: tasksJSON[randomKey]!)
    }
    
    /** Pick a scheduling policy, and notify for that task */
    func pickTaskToNotify(tasksJSON: [String: [String: String]]) -> Task {
        return pickRandom(tasksJSON: tasksJSON)
        // return pickLastSnoozed(tasksJSON: tasksJSON)
    }
}










