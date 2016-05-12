//
//  NotifyMicrotasks.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/18/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON
import UIKit

class NotifyMicrotasks {
    
    let tasksref = Firebase(url: "https://microreminders.firebaseio.com/Tasks")
    let microtasksref = Firebase(url: "https://microreminders.firebaseio.com/Microtasks")
    var activeNotifications = [String: UILocalNotification]() // Stores the IDs of all the tasks actively notified, won't notify if already reminded
    var context = [String]()
    var my_id = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    init(){
        
    }
    
    func notify(){
        tasksref.queryOrderedByChild("owner").queryEqualToValue(my_id).observeSingleEventOfType(.Value, withBlock: {snapshot in
            var tasks = JSON(snapshot.value) // Get each matching task
            tasks = self.inactiveTasks(tasks)
            
            var task_id = String()
            for (key, _) in tasks {
                task_id = key
                print("taskid", task_id)
            }
            
            self.microtasksref.queryOrderedByChild("owner").queryEqualToValue(task_id).observeSingleEventOfType(.Value, withBlock: {snapshot in
                let microtasks = JSON(snapshot.value)
                print("microtasks", microtasks)
                
                let microtasksAtBat = self.currentMicrotasks(tasks, microtasks: microtasks) // For each task, check the microtask at the current step
                print("microtasksAtBat", microtasksAtBat)

                let microtasksToNotify = self.matchingContext(microtasksAtBat)
                print("microtasksToNotify", microtasksToNotify)
                
                self.sendNotifications(microtasksToNotify) // If that microtask matches our context, notify
                print("sent notifications")
            })
        })
    }
    
    func inactiveTasks(tasks: JSON) -> JSON {
        var inactive = tasks
        for (key, _) in tasks {
            if (activeNotifications[key] != nil) {inactive[key] = nil} // Sets active tasks to nil going forward in processing
        }
        return inactive
    }
    
    func currentMicrotasks(tasks: JSON, microtasks: JSON) -> [String:JSON] {
        var atBat = [String:JSON]()
        var step = Int()
        var mtID = String()
        
        // Get all the microtasks, find the ones that are active and snag them
        for (_, t) in tasks {
            
            // If a task is active (marked nil), skip it
            if (t == nil) {continue}
            
            // If a task is completed, skip it
            if (t["completed"].stringValue == "true") {continue}
            
            step = Int(t["step"].double!) // Get the current step of the task
            print("step", step)
            
            mtID = t["microtasks"][step].stringValue
            atBat[mtID] = microtasks[mtID] // Grab that microtask and store it
        }
        return atBat
    }
    
    func matchingContext(mts: [String:JSON]) -> [String:JSON] {
        var matching = [String:JSON]()
        for (mtID, mt) in mts {
            if self.context.contains(mt["context"].stringValue) {
                matching[mtID] = mt
            }
        }
        return matching
    }
    
    func sendNotifications(mts: [String:JSON]) {
        var userInfo: [String:String]
        for (mtID, mt) in mts {
            print(mts)
            let notification = UILocalNotification()
            notification.alertBody = "Reminder: \(mt["description"].stringValue)!" // Give it the microtask description
            notification.category = "RESPOND_TO_MT_DEFAULT"
            
            userInfo = [String: String]()
            userInfo["microtask"] = mtID
            userInfo["owner"] = mt["owner"].stringValue // Store the microtask owner in the notification
            print("userinfo", userInfo)
            notification.userInfo = userInfo
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notification) // Send notification
            activeNotifications[mt["owner"].stringValue] = notification // Add to list of active notifications
        }
        print("active notificaitons", activeNotifications)
    }
    
    func getCurrentNotifications() /*-> [UILocalNotification]*/ {
        print(self.activeNotifications)
    }
    
    func setContext(context: [String]){
        self.context = context
    }
    
    func removeActiveNotification(notification: UILocalNotification){
        activeNotifications[notification.userInfo!["owner"] as! String] = nil
    }
    
    func markMTdone(notification: UILocalNotification) {
        // Mark the microtask as completed
        let mtID = notification.userInfo!["microtask"] as! String
        let mtRef = microtasksref.childByAppendingPath(mtID)
        mtRef.childByAppendingPath("completed").setValue(true)
        
        // Increment the step of the task
        let taskID = notification.userInfo!["owner"] as! String
        let taskRef = tasksref.childByAppendingPath(taskID)
        taskRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            let step = Int(JSON(snapshot.value)["step"].double!)
            print("step", step)
            taskRef.childByAppendingPath("step").setValue(step+1)
        })
        
        // remove the current active notification
        removeActiveNotification(notification)
    }
}




















