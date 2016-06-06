//
//  PostTask.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/8/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class PostTask {
    let ref = Firebase(url: "https://microreminders.firebaseio.com/Tasks")
    let _id: String
    
    init(_id: String){
        self._id = _id // set the post UUID
    }
    
    // Each task will hold an owner, completion date, description, completed boolean, current step (which task are we on), and a dictionary of MTs. The MTs are stored as [order: UUID].
    func post(owner: String, completionDate: String, description: String, completed: Bool, microtasks: [String: String], step: Int) {
        
        let time = date_to_string()
        
        let task = ["owner": owner, "completionDate": completionDate, "description": description, "completed": completed, "microtasks": microtasks, "step": step, "timeStarted": time]
        
        ref.childByAppendingPath(_id).setValue(task as AnyObject)
    }
    
}