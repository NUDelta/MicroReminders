//
//  TaskLandingPageViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/12/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class TaskLandingPageViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var enterTask: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterTask.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        enterTask.resignFirstResponder()
        return true
    }
    
    @IBAction func sendCustomTask(_ sender: UIButton) {
        if (enterTask.text != "") {
            let task = Task(
                UUID().uuidString,
                name: enterTask.text!,
                category1: "user_entered",
                category2: "user_entered",
                category3: "user_entered",
                mov_sta: "user_entered"
            )
            
            task.pickLocationAndPushTask(self)
            enterTask.text = ""
        }
    }
}
