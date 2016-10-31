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
            "t_timeSinceNotified":task.timeSinceNotified
        ]
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
//    func pickTaskToNotify(tasksJSON: [String: [String: String]]) -> Task {
//        
//    }
    
    func notify(_ region: String) {
        let myTasksRef = FIRDatabase.database().reference().child("Tasks/\(myId)")
        
        myTasksRef.observeSingleEvent(of: .value, with: { snapshot in
            let tasksJSON = snapshot.value as? Dictionary<String, Dictionary<String, String>>
            
            if tasksJSON != nil {
                for (_id, taskData) in tasksJSON! {
                    if (taskData["location"]!.lowercased() == region){
                        let task = Task(
                            _id,
                            name: taskData["task"]!,
                            category1: taskData["category1"]!,
                            category2: taskData["category2"]!,
                            category3: taskData["category3"]!,
                            mov_sta: taskData["mov_sta"]!,
                            location: taskData["location"]!,
                            completed: taskData["completed"]!,
                            timeSinceNotified: taskData["timeSinceNotified"]!
                        )
                        
                        self.sendNotification(task)
                    }
                }
            }
        })
    }

}
