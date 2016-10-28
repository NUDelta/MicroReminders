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
    
    
    func sendNotifications(tasks: [Task]) {
        for task in tasks {
            let notif = UILocalNotification()
            notif.alertBody = "Reminder: \(task.name)!"
            notif.category = "RESPOND_TO_MT_DEFAULT"
            
            let userInfo = ["task":task.name]
            notif.userInfo = userInfo
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notif)
        }
    }
    
    func notify(region: String) {
        let myTasksRef = FIRDatabase.database().reference().child("Tasks/\(myId)")
        var tasks = [Task]()
        
        myTasksRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let tasksJSON = snapshot.value as? NSDictionary
            
            if tasksJSON != nil {
                for (_id, taskData) in tasksJSON! {
                    var taskDict = taskData as! Dictionary<String, String>
                    
                    if (taskDict["location"]!.lowercaseString == region){
                        let task = Task(_id as! String, taskDict["task"]!, taskDict["category1"]!, taskDict["category2"]!,
                            taskDict["category3"]!, taskDict["mov_sta"]!, taskDict["location"]!)
                        
                        tasks.append(task)
                    }
                }
            }
            
            self.sendNotifications(tasks)
        })
    }

}