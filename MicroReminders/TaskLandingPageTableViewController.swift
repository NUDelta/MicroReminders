//
//  TaskLandingPageTableTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/14/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class TaskLandingPageTableViewController: UITableViewController {
    
    var prepopTaskRef: FIRDatabaseReference!
    var myTaskRef: FIRDatabaseReference!
    
    var prepopTaskList = [Task]()
    var myTaskList = [Task]()
    var displayTaskList = [Task]()
    
    var tappedCell = -1

    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        prepopTaskRef = FIRDatabase.database().reference().child("Tasks/Prepopulated")
        myTaskRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayTasks()
    }
    
    func updateDisplayTasks() -> Void {
        prepopTaskRef.observeSingleEvent(of: .value, with: { prepopSnapshot in
            self.fillTaskList(prepopSnapshot, taskList: &self.prepopTaskList)
            
            self.myTaskRef.observeSingleEvent(of: .value, with: { myTaskSnapshot in
                self.fillTaskList(myTaskSnapshot, taskList: &self.myTaskList)
                
                let myTaskIds = self.myTaskList.map({ task in task._id })
                self.displayTaskList = self.prepopTaskList.filter({ task in !myTaskIds.contains(task._id) })
                
                self.displayTaskList.sort(by: { (task1, task2) in task1.name < task2.name })
                self.tableView.reloadData()
            })
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
                    category1: taskData["category1"]!,
                    category2: taskData["category2"]!,
                    category3: taskData["category3"]!,
                    mov_sta: taskData["mov_sta"]!,
                    location: taskData["location"]!,
                    completed: taskData["completed"]!,
                    lastSnoozed: taskData["lastSnoozed"]!
                )
                
                taskList.append(task)
            }
        }
    }

    // Table display
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTaskList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskLandingPageCell", for: indexPath) as! TaskLandingPageCell

        let task = displayTaskList[indexPath.row]
        cell.taskName.text = task.name
        cell.taskTime.text = task.length

        return cell
    }
    
    // Table interaction
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskInd = indexPath.row
        if (tappedCell == indexPath.row) {
            displayTaskList[taskInd].pickLocationAndPushTask(self)
        }
        
        tappedCell = taskInd
    }
}




















