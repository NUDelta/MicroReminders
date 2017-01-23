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

class AddTaskViewController: UIViewController {
    
    let myTasksRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
    let myPrepopRef = FIRDatabase.database().reference().child("Tasks/Prepopulated")
    
    private var embeddedTableViewController: AddTaskTableViewController!
    var selectedTask: Task!
    var taskCategory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let adtvc = segue.destination as? AddTaskTableViewController, segue.identifier == "AddTaskEmbed" {
            adtvc.taskCategory = taskCategory
            self.embeddedTableViewController = adtvc
        }
        else if let tcvc = segue.destination as? TaskConstraintViewController, segue.identifier == "constrainTask" {
            tcvc.task = selectedTask
            tcvc.pushHandler = {
                let _ = self.navigationController?.popViewController(animated: true)
                self.embeddedTableViewController.updateDisplayTasks()
//                self.tabBarController!.selectedIndex = 1
            }
        }
    }
    
    @IBAction func addCustomTask(_ sender: UIBarButtonItem) {
        var taskName = ""
        let category = taskCategory!
        
        struct textFieldAndAction {
            var tf: UITextField
            var action: UIAlertAction
            
            init(tf: UITextField, action: UIAlertAction) {
                self.tf = tf
                self.action = action
            }
        }
        
        // Write a task
        let taskAlert = UIAlertController(title: "Custom task", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Add", style: .default, handler: { (_) in
            taskName = taskAlert.textFields![0].text! // Get entered task name
            
            self.selectedTask = Task(UUID().uuidString, name: taskName, category: category, subcategory: "Personal")
            self.performSegue(withIdentifier: "constrainTask", sender: self)
            
        })
        continueAction.isEnabled = false
        taskAlert.addTextField(configurationHandler: { tf in
            tf.placeholder = "Add a custom task..."
            tf.addTarget(self, action: #selector(self.blockAlertDismiss), for: .editingChanged)
        })
        taskAlert.addAction(continueAction)
        taskAlert.addAction(cancelAction)
        
        self.present(taskAlert, animated: true, completion: nil)
    }
    
    func blockAlertDismiss(_ sender: UITextField) {
        var resp: UIResponder! = sender
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = !sender.text!.isEmpty
    }
}















