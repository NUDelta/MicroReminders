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
    let myId = UIDevice.current.identifierForVendor!.uuidString
    
    
    func sendNotification(_ task: Task) {
        let notif = UILocalNotification()
        notif.alertBody = "Reminder: \(task.name)!"
        notif.category = "RESPOND_TO_MT_DEFAULT"
        
        let userInfo = ["task":task.name]
        notif.userInfo = userInfo
        
        UIApplication.shared.presentLocalNotificationNow(notif)
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
