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
    private static let sharedInstance = Tasks()
    private static let tasksRef = FIRDatabase.database().reference().child("Tasks/\(userKey)")
    
    var tasks: [Task]?
    
    static func getTasks(then handler: @escaping ([Task]) -> Void) {
        let tasks = Tasks.sharedInstance.tasks
        if (tasks != nil) {
            handler(tasks!)
        }
        else {
            Tasks.sharedInstance.queryTasks(then: handler)
        }
    }
    
    private init() {
        listenToTasks()
    }
    
    private func listenToTasks() {
        Tasks.tasksRef.observe(.value, with: {snapshot in
            self.tasks = Tasks.fillTaskList(snapshot)
        })
    }
    
    private func queryTasks(then handler: @escaping ([Task]) -> Void) {
        Tasks.tasksRef.observeSingleEvent(of: .value, with: {snapshot in
            self.tasks = Tasks.fillTaskList(snapshot)
            handler(self.tasks!)
        })
    }
    
    private static func fillTaskList(_ snapshot: FIRDataSnapshot) -> [Task] {
        var taskList = [Task]()
        let taskJSON = snapshot.value as? [String: [String: String]]
        
        if taskJSON != nil {
            for (_id, taskData) in taskJSON! {
                let task = Task(
                    _id,
                    name: taskData["task"]!,
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















