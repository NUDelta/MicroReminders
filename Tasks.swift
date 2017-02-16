//
//  Tasks.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/16/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class Tasks {
    static let sharedInstance = Tasks()
    fileprivate let tasksRef: FIRDatabaseReference!
    
    var tasks = [Task]()
    
    fileprivate init() {
        tasksRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
        
        tasksRef.observe(.value, with: {snapshot in
            self.tasks = self.fillTaskList(snapshot)
        })
    }
    
    fileprivate func fillTaskList(_ snapshot: FIRDataSnapshot) -> [Task] {
        var taskList = [Task]()
        let taskJSON = snapshot.value as? [String: [String: String]]
        
        if taskJSON != nil {
            for (_id, taskData) in taskJSON! {
                let task = Task(
                    _id,
                    name: taskData["task"]!,
                    category: taskData["category"]!,
                    subcategory: taskData["subcategory"]!,
                    location: taskData["location"]!,
                    beforeTime: taskData["beforeTime"]!,
                    afterTime: taskData["afterTime"]!,
                    completed: taskData["completed"]!,
                    lastSnoozed: taskData["lastSnoozed"]!
                )
                
                taskList.append(task)
            }
        }
        
        return taskList
    }
}















