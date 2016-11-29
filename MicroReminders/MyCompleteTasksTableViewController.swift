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
    var displayTaskDict = [String: [Task]]()
    var displayTaskDictComplete = [String: [Task]]()
    
    var tappedCell = -1
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        myTaskRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayTasks()
    }
    
    // Table display
    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayTaskDict.keys.count + displayTaskDictComplete.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extractSection(section: section).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCompleteTasksTableCell", for: indexPath) as! MyCompleteTasksTableCell
        
        let task = extractSection(section: indexPath.section)[indexPath.row]
        
        if (indexPath.section < displayTaskDict.keys.count) {
            cell.taskName.text = task.name
            cell.subcategory.text = "[\(task.subcategory)]"
            cell.active = true
            cell.button.setTitle("☐", for: .normal)
            cell.time.text = "\(task.length)"
        }
        else {
            cell.taskName.attributedText = NSAttributedString(string: task.name, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
            cell.subcategory.attributedText = NSAttributedString(string: "[\(task.subcategory)]", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
            cell.time.attributedText = NSAttributedString(string: "\(task.length)", attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
            cell.active = false
            cell.button.setTitle("☑︎", for: .normal)
        }
        cell.task = task
        cell.tableViewController = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return extractSectionKey(section: section)
    }
    
    func updateDisplayTasks() -> Void {
        func taskDictInsert(dict: inout [String: [Task]], task: Task) {
            let key = task.category
            if dict[key] == nil { dict[key] = [Task]() }
            dict[key]!.append(task)
        }
        
        func taskDictSort(dict: inout [String: [Task]]) {
            for (category, tasklist) in dict {
                let sorted = tasklist.sorted(by: { (task1, task2) in task1.subcategory < task2.subcategory })
                dict[category] = sorted
            }
        }
        
        self.myTaskRef.observeSingleEvent(of: .value, with: { myTaskSnapshot in
            self.fillTaskList(myTaskSnapshot, taskList: &self.myTaskList)
            self.displayTaskList = self.myTaskList
            self.displayTaskDict = [String: [Task]]()
            self.displayTaskDictComplete = [String: [Task]]()
            
            for task in self.displayTaskList {
                if task.completed == "false" { taskDictInsert(dict: &self.displayTaskDict, task: task) }
                else { taskDictInsert(dict: &self.displayTaskDictComplete, task: task) }
            }
            
            taskDictSort(dict: &self.displayTaskDict)
            taskDictSort(dict: &self.displayTaskDictComplete)
            
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
    
    func extractSection(section: Int) -> [Task] {
        let incompleteCategoryCount = displayTaskDict.keys.count
        
        if section < incompleteCategoryCount {
            let sectionkey = Array(displayTaskDict.keys).sorted(by: { (cat1, cat2) in cat1 < cat2 })[section]
            return displayTaskDict[sectionkey]!
        }
        else {
            let mod = section - incompleteCategoryCount
            let sectionkey = Array(displayTaskDictComplete.keys).sorted(by: { (cat1, cat2) in cat1 < cat2 })[mod]
            return displayTaskDictComplete[sectionkey]!
        }
    }
    
    func extractSectionKey(section: Int) -> String {
        let incompleteCategoryCount = displayTaskDict.keys.count
        
        if section < incompleteCategoryCount {
            return Array(displayTaskDict.keys).sorted(by: { (cat1, cat2) in cat1 < cat2 })[section]
        }
        else {
            let mod = section - incompleteCategoryCount
            return Array(displayTaskDictComplete.keys).sorted(by: { (cat1, cat2) in cat1 < cat2 })[mod] + " (complete)"
        }
    }
}













