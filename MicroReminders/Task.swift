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
    let name: String
    let category: String
    let subcategory: String
    let length: String = "1 min"
    var location: String = "unassigned"
    var lastSnoozed: String = "-1"
    
    let created: String = String(Date().timeIntervalSince1970)
    var completed: String = "false"
    
    init(_ _id: String, name: String, category: String, subcategory: String) {
        self._id = _id
        self.name = name
        self.category = category
        self.subcategory = subcategory
        self.lastSnoozed = timeRightNow()
    }
    
    init(_ _id: String, name: String, category: String, subcategory: String, location: String, completed: String, lastSnoozed: String) {
        self._id = _id
        self.name = name
        self.category = category
        self.subcategory = subcategory
        self.location = location
        self.completed = completed
        self.lastSnoozed = timeRightNow()
    }
    
    /** Create a copy of a task - completed and created are reset */
    init(task: Task) {
        self._id = UUID().uuidString
        self.name = task.name
        self.category = task.category
        self.subcategory = task.subcategory
        self.location = task.location
        self.lastSnoozed = timeRightNow()
    }
    
    func timeRightNow() -> String {
        return String(Int(Date().timeIntervalSince1970))
    }
    
    func pushToFirebase(handler: (() -> Void)!) -> Void {
        let myTaskRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
        
        myTaskRef.child(_id).setValue([
            "task":name,
            "category":category,
            "subcategory":subcategory,
            "length":length,
            "location":location,
            "completed":completed,
            "lastSnoozed":lastSnoozed,
            "created":created
            ], withCompletionBlock: { (err, ref) in
                if handler != nil {
                    handler()
                }
        })
    }
    
    func pickLocationAndPushTask(_ parentViewController: UIViewController, handler: (() -> Void)!) {
        let actionSheet = UIAlertController(title: "Please pick a room!", message: "Select a room", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
        actionSheet.addAction(cancelActionButton)
        
        var actionButton: UIAlertAction
        for name in Beacons.sharedInstance.beacons.values {
            actionButton = UIAlertAction(title: name.capitalized, style: .default, handler: { (action) -> Void in
                self.location = action.title!.lowercased()
                self.lastSnoozed = self.timeRightNow()
                self.pushToFirebase(handler: handler)
                
                let alert = UIAlertController(title: "Task added!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                parentViewController.present(alert, animated: true, completion: nil)
            })
            actionSheet.addAction(actionButton)
        }
        
        parentViewController.present(actionSheet, animated: true, completion: nil)
    }
}






















