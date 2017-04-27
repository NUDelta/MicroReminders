//
//  Task.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/22/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Firebase

class Task {
    let _id: String
    var name: String
    var length: String = "<1 min"
    var location: String = "unassigned"
    var afterTime: String = "unassigned"
    var beforeTime: String = "unassigned"
    var lastSnoozed: String = "-1"
    // There is a goal field added, don't forget about it
    
    let created: String = String(Int(Date().timeIntervalSince1970))
    var completed: String = "false"
    
    init(_ _id: String, name: String) {
        self._id = _id
        self.name = name
        self.lastSnoozed = timeRightNow()
    }
    
    init(_ _id: String, name: String, location: String, beforeTime: String, afterTime: String, completed: String, lastSnoozed: String) {
        self._id = _id
        self.name = name
        self.completed = completed
        self.lastSnoozed = timeRightNow()
        
        self.location = location
        self.beforeTime = beforeTime
        self.afterTime = afterTime
    }
    
    /** Create a copy of a task - completed and created are reset */
    init(task: Task) {
        self._id = UUID().uuidString
        self.name = task.name
        self.location = task.location
        self.lastSnoozed = timeRightNow()
    }
    
    func timeRightNow() -> String {
        return String(Int(Date().timeIntervalSince1970))
    }
    
    func pushToFirebase(handler: (() -> Void)!) -> Void {
        let myTaskRef = FIRDatabase.database().reference().child("Habits/\(UserConfig.shared.userKey)")
        
        myTaskRef.child(_id).setValue([
            "task":name,
            "length":length,
            "location":location,
            "completed":completed,
            "lastSnoozed":lastSnoozed,
            "created":created,
            "afterTime":afterTime,
            "beforeTime":beforeTime
            ], withCompletionBlock: { (err, ref) in
                if handler != nil {
                    handler()
                }
        })
    }
}






















