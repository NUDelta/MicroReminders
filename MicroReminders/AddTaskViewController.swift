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
    let myPrepopRef = FIRDatabase.database().reference().child("Tasks/Prepopulated_Tasks")
    
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
            }
        }
        else if let ctcvc = segue.destination as? CustomTaskConstraintViewController, segue.identifier == "constrainCustomTask" {
            ctcvc.taskCategory = taskCategory
            ctcvc.pushHandler = {
                let _ = self.navigationController?.popViewController(animated: true)
                self.embeddedTableViewController.updateDisplayTasks()
            }
        }
    }
    
    @IBAction func addCustomTask(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "constrainCustomTask", sender: self)
        
    }
    
    func blockAlertDismiss(_ sender: UITextField) {
        var resp: UIResponder! = sender
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = !sender.text!.isEmpty
    }
}















