//
//  MyTasksTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/22/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class MyIncompleteTasksTableViewController: UITableViewController {
    var myTaskRef: FIRDatabaseReference!

    var myTaskList = [Task]()
    var displayTaskList = [Task]()
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyIncompleteTasksTableCell", for: indexPath) as! MyIncompleteTasksTableCell
        
        let task = displayTaskList[indexPath.row]
        cell.taskName.text = task.name
        cell.taskTime.text = "1 min"
        
        return cell
    }
    
    // Table interaction
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(myTaskList[indexPath.row])
    }
    
    func updateDisplayTasks() -> Void {
        myTaskList = [Task]()
        self.myTaskRef.observeSingleEvent(of: .value, with: { myTaskSnapshot in
            self.fillTaskList(myTaskSnapshot, taskList: &self.myTaskList)
            self.displayTaskList = self.myTaskList.filter({ task in task.completed == "false" })
            
            self.displayTaskList.sort(by: { (task1, task2) in task1.name < task2.name })
            self.tableView.reloadData()
        })
    }
    
    func fillTaskList(_ snapshot: FIRDataSnapshot, taskList: inout [Task]) -> Void {
        let taskJSON = snapshot.value as? Dictionary<String, Dictionary<String, String>>
        
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
                    timeSinceNotified: taskData["timeSinceNotified"]!
                )
                
                taskList.append(task)
            }
        }
    }
}
