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
    let category1: String
    let category2: String
    let category3: String
    let mov_sta: String
    let length: String = "1 min"
    var location: String = "unassigned"
    var timeSinceNotified: Int = Int.max
    
    init(_ _id: String, _ name: String, _ category1: String, _ category2: String, _ category3: String, _ mov_sta: String) {
        self._id = _id
        self.name = name
        self.category1 = category1
        self.category2 = category2
        self.category3 = category3
        self.mov_sta = mov_sta
    }
    
    init(_ _id: String, _ name: String, _ category1: String, _ category2: String, _ category3: String, _ mov_sta: String, _ location: String) {
        self._id = _id
        self.name = name
        self.category1 = category1
        self.category2 = category2
        self.category3 = category3
        self.mov_sta = mov_sta
        self.location = location
    }
    
    func pushToFirebase() -> Void {
        let myTaskRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
        
        myTaskRef.child(_id).setValue(["task":name, "category1":category1, "category2":category2, "category3":category3, "mov_sta":mov_sta, "length":length, "location":location])
    }
    
    func pickLocationAndPushTask(_ parentViewController: UIViewController) {
        let actionSheet = UIAlertController(title: "Please pick a room!", message: "Select a room", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
        actionSheet.addAction(cancelActionButton)
        
        var actionButton: UIAlertAction
        for name in Beacons.sharedInstance.beacons.values {
            actionButton = UIAlertAction(title: name.capitalized, style: .default, handler: { [unowned self] (action) -> Void in
                
                self.location = action.title!
                self.pushToFirebase()
                
                let alert = UIAlertController(title: "Task added!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                parentViewController.present(alert, animated: true, completion: nil)
            })
            actionSheet.addAction(actionButton)
        }
        
        parentViewController.present(actionSheet, animated: true, completion: nil)
    }
}






















