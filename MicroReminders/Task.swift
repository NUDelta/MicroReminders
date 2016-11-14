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
    
    func pushToFirebase() -> Void {
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
            ])
    }
    
    func pickLocationAndPushTask(_ parentViewController: UIViewController) {
        let actionSheet = UIAlertController(title: "Please pick a room!", message: "Select a room", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
        actionSheet.addAction(cancelActionButton)
        
        var actionButton: UIAlertAction
        for name in Beacons.sharedInstance.beacons.values {
            actionButton = UIAlertAction(title: name.capitalized, style: .default, handler: { (action) -> Void in
                self.location = action.title!.lowercased()
                self.lastSnoozed = self.timeRightNow()
                self.pushToFirebase()
                
                let alert = UIAlertController(title: "Task added!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                parentViewController.present(alert, animated: true, completion: nil)
            })
            actionSheet.addAction(actionButton)
        }
        
        parentViewController.present(actionSheet, animated: true, completion: nil)
    }
    
    func viewTaskDetailAlert(_ parentViewController: UIViewController) {
        let alert = UIAlertController(title: "\(self.name)", message: displayMessageString(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        parentViewController.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func createdMessageString() -> String {
        return "Created: " + secondsStringToTime(self.created, formatStyle: .medium)
    }
    
    fileprivate func completedMessageString() -> String? {
        if (self.completed == "false") {
            return nil
        }
        else {
            return "Completed: " + secondsStringToTime(self.completed, formatStyle: .medium)
        }
    }
    
    fileprivate func lastSnoozedMessageString() -> String? {
        if (self.lastSnoozed == "-1") {
            return nil
        }
        else {
            return "Last snoozed: " + secondsStringToTime(self.lastSnoozed, formatStyle: .medium)
        }
    }
    
    fileprivate func lengthMessageString() -> String {
        return "Estimated duration: " + self.length
    }
    
    fileprivate func locationMessageString() -> String? {
        if (self.location == "unassigned") {
            return nil
        }
        else {
            return "Assigned location: " + self.location
        }
    }
    
    fileprivate func displayMessageString() -> String {
        var message = ""
        let chunks: [String?] = [
            createdMessageString(),
            completedMessageString(),
            lastSnoozedMessageString(),
            lengthMessageString(),
            locationMessageString()
        ]
        
        for chunk in chunks {
            if chunk != nil {
                message.append(String(format: "%C \(chunk!)\n", 0x2022 as unichar))
            }
        }
        return message
    }
    
    fileprivate func secondsStringToTime(_ time: String, formatStyle: DateFormatter.Style) -> String {
        let doubleTime = Double(time)!
        let formatter = DateFormatter()
        formatter.dateStyle = formatStyle
        return formatter.string(for: Date(timeIntervalSince1970: doubleTime))!
    }
}






















