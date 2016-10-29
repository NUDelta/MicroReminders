//
//  Notify.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/28/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class Notify {
    let myId = UIDevice.currentDevice().identifierForVendor!.UUIDString
    
    
    func sendNotification(task: Task) {
        let notif = UILocalNotification()
        notif.alertBody = "Reminder: \(task.name)!"
        notif.category = "RESPOND_TO_MT_DEFAULT"
        
        let userInfo = ["task":task.name]
        notif.userInfo = userInfo
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notif)
    }
    
//    func pickTaskToNotify(tasksJSON: [String: [String: String]]) -> Task {
//        
//    }
    
    func notify(region: String) {
        let myTasksRef = FIRDatabase.database().reference().child("Tasks/\(myId)")
        
        myTasksRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let tasksJSON = snapshot.value as? Dictionary<String, Dictionary<String, String>>
            
            if tasksJSON != nil {
                for (_id, taskData) in tasksJSON! {
                    if (taskData["location"]!.lowercaseString == region){
                        let task = Task(_id, taskData["task"]!, taskData["category1"]!, taskData["category2"]!,
                            taskData["category3"]!, taskData["mov_sta"]!, taskData["location"]!)
                        
                        self.sendNotification(task)
                    }
                }
            }
        })
    }

}