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
        
        let userInfo = ["task":task.name]
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
                        let task = Task(_id, taskData["task"]!, taskData["category1"]!, taskData["category2"]!,
                            taskData["category3"]!, taskData["mov_sta"]!, taskData["location"]!)
                        
                        self.sendNotification(task)
                    }
                }
            }
        })
    }

}
