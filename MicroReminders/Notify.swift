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

class Notify {
    let myId = UIDevice.current.identifierForVendor!.uuidString
    let requestIdentifier = "reminder"
    
    func sendNotification(_ task: Task) {
        print("Notifying \(task.name)")
        let content = UNMutableNotificationContent()
        content.title = "Reminder!"
        content.body = "\(task.name)"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "respond_to_task"
        
        let userInfo = [
            "t_id":task._id,
            "t_name":task.name,
            "t_category1":task.category1,
            "t_category2":task.category2,
            "t_category3":task.category3,
            "t_completed":task.completed,
            "t_length":task.length,
            "t_location":task.location,
            "t_mov_sta":task.mov_sta,
            "t_lastSnoozed":task.lastSnoozed
        ]
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /** Build a task from a dictionary entry from Firebase */
    func dictToTask(_id: String, taskJSON: [String: String]) -> Task {
        return Task(
            _id,
            name: taskJSON["task"]!,
            category1: taskJSON["category1"]!,
            category2: taskJSON["category2"]!,
            category3: taskJSON["category3"]!,
            mov_sta: taskJSON["mov_sta"]!,
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
        // return pickRandom(tasksJSON: tasksJSON)
        return pickLastSnoozed(tasksJSON: tasksJSON)
    }
    
    func notify(_ region: String) {
        let myTasksRef = FIRDatabase.database().reference().child("Tasks/\(myId)")
        
        myTasksRef.observeSingleEvent(of: .value, with: { snapshot in
            let tasksJSON = snapshot.value as? [String: [String: String]]
            
            if tasksJSON != nil {
                let taskToNotify = self.pickTaskToNotify(tasksJSON: tasksJSON!)
                self.sendNotification(taskToNotify)
            }
        })
    }

}
