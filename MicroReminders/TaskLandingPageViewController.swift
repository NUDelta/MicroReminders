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
    
    private var embeddedTableViewController: TaskLandingPageTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterTask.delegate = self
        
        if firstTime() { firstTimeAlert() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TaskLandingPageTableViewController, segue.identifier == "LandingPageEmbed" {
            self.embeddedTableViewController = vc
        }
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
                category: "user_entered",
                subcategory: "user_entered"
            )
            
            task.pickLocationAndPushTask(self)
            enterTask.text = ""
        }
    }
    
    @IBAction func addTaskFromList(_ sender: UIButton) {
        if let selectedTask = embeddedTableViewController.tappedCell {
            selectedTask.pickLocationAndPushTask(self)
        }
    }
    
    @IBAction func viewTask(_ sender: UIButton) {
        if let selectedTask = embeddedTableViewController.tappedCell {
            selectedTask.viewTaskDetailAlert(self)
        }
    }
    
    fileprivate func firstTime() -> Bool {
        return !UserDefaults().bool(forKey: "addingFirstTime")
    }
    
    fileprivate func firstTimeAlert() {
        UserDefaults().set(true, forKey: "addingFirstTime")
        
        let message = "Here, you can see suggested tasks you might be interested in."
        let alert = UIAlertController(title: "View your suggested tasks!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}















