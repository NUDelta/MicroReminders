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
    var taskCategory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddTaskTableViewController, segue.identifier == "AddTaskEmbed" {
            vc.taskCategory = taskCategory
            self.embeddedTableViewController = vc
        }
    }
    
    @IBAction func addCustomTask(_ sender: UIBarButtonItem) {
        var taskName = ""
        let category = taskCategory!
        var subcategory = ""
        
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
        let continueAction = UIAlertAction(title: "Accept", style: .default, handler: { (_) in
            taskName = taskAlert.textFields![0].text! // Get entered task name
            
            // Pick category - pull prepop and my tasks from FB and set union categories
            let sheet = UIAlertController(title: "Categorize your task", message: "Pick a subcategory for your task", preferredStyle: .actionSheet)
            
            var subcategories = Set<String>()
            self.myPrepopRef.observeSingleEvent(of: .value, with: { ppsnapshot in
                self.fillSubcategories(snapshot: ppsnapshot, category: self.taskCategory!, subcategories: &subcategories)
                self.myTasksRef.observeSingleEvent(of: .value, with: { mysnapshot in
                    self.fillSubcategories(snapshot: mysnapshot, category: self.taskCategory!, subcategories: &subcategories)
                    
                    // Add a button for each subcategory
                    for sc in subcategories {
                        sheet.addAction(UIAlertAction(title: sc, style: .default, handler: { alert in
                            subcategory = alert.title!
                            Task(UUID().uuidString, name: taskName, category: category, subcategory: subcategory).pickLocationAndPushTask(self, handler: { self.embeddedTableViewController.updateDisplayTasks() })
                        }))
                    }
                    
                    // Add a button to enter a custom subcategory
                    sheet.addAction(UIAlertAction(title: "Custom...", style: .default, handler: { action in
                        let categoryAlert = UIAlertController(title: "Custom subcategory", message: "Create a new subcategory", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        let continueAction = UIAlertAction(title: "Accept", style: .default, handler: { c_alert in
                            subcategory = categoryAlert.textFields![0].text!
                            Task(UUID().uuidString, name: taskName, category: category, subcategory: subcategory).pickLocationAndPushTask(self, handler: { self.embeddedTableViewController.updateDisplayTasks() })
                        })
                        continueAction.isEnabled = false
                        
                        
                        categoryAlert.addTextField(configurationHandler: { tf in
                            tf.placeholder = "Add a custom task..."
                            tf.addTarget(self, action: #selector(self.blockAlertDismiss), for: .editingChanged)
                        })
                        
                        categoryAlert.addAction(continueAction)
                        categoryAlert.addAction(cancelAction)
                        
                        self.present(categoryAlert, animated: true, completion: nil)
                    }))
                    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(sheet, animated: true, completion: {
                        Task(UUID().uuidString, name: taskName, category: category, subcategory: subcategory).pickLocationAndPushTask(self, handler: { self.embeddedTableViewController.updateDisplayTasks() })
                    })
                })
            })
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
    
    fileprivate func fillSubcategories(snapshot: FIRDataSnapshot, category: String, subcategories: inout Set<String>) {
        let json = snapshot.value as? [String: [String: String]]
        if json != nil {
            for (_, value) in json! {
                if (value["category"]! == category) {
                    subcategories.insert(value["subcategory"]!)
                }
            }
        }
    }
    
    @IBAction func addTaskFromList(_ sender: UIButton) {
        if let selectedTask = embeddedTableViewController.tappedCell {
            selectedTask.pickLocationAndPushTask(self, handler: { self.embeddedTableViewController.updateDisplayTasks() })
        }
    }
}















