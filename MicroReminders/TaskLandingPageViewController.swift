//
//  TaskLandingPageViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/12/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
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
            let task = Task(UUID().uuidString, enterTask.text!, "user_entered", "user_entered", "user_entered", "user_entered")
            
            task.pickLocationAndPushTask(self)
            enterTask.text = ""
        }
    }
}
