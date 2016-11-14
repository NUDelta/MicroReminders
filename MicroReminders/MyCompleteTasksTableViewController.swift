//
//  MyCompleteTasksTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class MyCompleteTasksTableViewController: UITableViewController {
    var myTaskRef: FIRDatabaseReference!
    
    var myTaskList = [Task]()
    var displayTaskList = [Task]()
    
    var tappedCell = -1
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        myTaskRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayTasks()
    }
    
    // Table display
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTaskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCompleteTasksTableCell", for: indexPath) as! MyCompleteTasksTableCell
        
        let task = displayTaskList[indexPath.row]
        cell.taskName.text = task.name
        cell.task = task
        cell.tableViewController = self
        
        return cell
    }
    
    // Table interaction
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskInd = indexPath.row
        if (tappedCell == indexPath.row) {
            let task = displayTaskList[tappedCell]
            let actionSheet = UIAlertController(title: "Reactivate task: \(task.name)?", message: "Would you like to reactivate this task?", preferredStyle: .actionSheet)
            
            let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
            actionSheet.addAction(cancelActionButton)
            
            let reactivateActionButton = UIAlertAction(title: "Reactivate", style: .default, handler: { (action) in
                Task(task: task).pushToFirebase()
            })
            actionSheet.addAction(reactivateActionButton)
            
            let reactivateNewLocActionButton = UIAlertAction(title: "Reactivate with new location", style: .default, handler: { (action) in Task(task: task).pickLocationAndPushTask(self) })
            actionSheet.addAction(reactivateNewLocActionButton)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
        
        tappedCell = taskInd
    }
    
    func updateDisplayTasks() -> Void {
        self.myTaskRef.observeSingleEvent(of: .value, with: { myTaskSnapshot in
            self.fillTaskList(myTaskSnapshot, taskList: &self.myTaskList)
            self.displayTaskList = self.myTaskList.filter({ task in task.completed != "false" })
            
            self.displayTaskList.sort(by: { (task1, task2) in task1.name < task2.name })
            self.tableView.reloadData()
        })
    }
    
    func fillTaskList(_ snapshot: FIRDataSnapshot, taskList: inout [Task]) -> Void {
        taskList = [Task]()
        
        let taskJSON = snapshot.value as? [String: [String: String]]
        
        if taskJSON != nil {
            for (_id, taskData) in taskJSON! {
                let task = Task(
                    _id,
                    name: taskData["task"]!,
                    category: taskData["category"]!,
                    subcategory: taskData["subcategory"]!,
                    location: taskData["location"]!,
                    completed: taskData["completed"]!,
                    lastSnoozed: taskData["lastSnoozed"]!
                )
                
                taskList.append(task)
            }
        }
    }
}
