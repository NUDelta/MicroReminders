//
//  MyTasksTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class TaskList: UITableViewController {
    
    var displayTaskDict = [String: [Task]]()
    var displayTaskDictComplete = [String: [Task]]()
    
    var existingTaskToConstrain: Task!
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.title = "TEST CHANGE THIS"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayTasks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // nothing now, like the stub tho
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ctcvc = segue.destination as? TaskConstraintViewController {
            ctcvc.pushHandler = {
                self.navigationController!.popViewController(animated: true)
            }
            
            if segue.identifier == "constrainExistingTask" {
                ctcvc.existingTask = existingTaskToConstrain
            }
        }
    }
}

// TableView data source and delegate
extension TaskList {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayTaskDict.keys.count + displayTaskDictComplete.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extractSection(section: section).count
    }
    
    func capitalizeFirstLetter(_ string: String) -> String {
        let first = String(string.characters.prefix(1)).capitalized
        let other = String(string.characters.dropFirst())
        return first + other
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let task = extractSection(section: indexPath.section)[indexPath.row]
        
        if (task.location == "unassigned") {
            cell.backgroundColor = UIColor.white
            cell.button.setTitle("＋", for: .normal)
            cell.location.text = "Add location:"
        }
        else if (indexPath.section < displayTaskDict.keys.count) {
            cell.backgroundColor = UIColor.white
            cell.button.setTitle("☐", for: .normal)
            cell.location.text = "\(capitalizeFirstLetter(task.location))"
        }
        else {
            cell.backgroundColor = UIColor.lightGray
            cell.button.setTitle("☑︎", for: .normal)
            cell.location.text = "\(capitalizeFirstLetter(task.location))"
        }
        cell.task = task
        cell.tableViewController = self
        cell.time.text = "⏳ ~1min"
        cell.taskName.text = task.name
        
        // Hotfix for tasks staying bolded
        cell.taskName.font = UIFont.systemFont(ofSize: cell.taskName.font.pointSize)
        cell.location.font = UIFont.systemFont(ofSize: cell.location.font.pointSize)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = extractSectionKey(section: indexPath.section)
        
        if section == "Pending" {
            let cell = tableView.cellForRow(at: indexPath) as! TaskCell
            
            cell.taskName.font = UIFont.boldSystemFont(ofSize: cell.taskName.font.pointSize)
            cell.location.font = UIFont.boldSystemFont(ofSize: cell.location.font.pointSize)
            
            let alert = UIAlertController(title: "Edit task?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in cell.constrainExistingTask() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        
        cell.taskName.font = UIFont.systemFont(ofSize: cell.taskName.font.pointSize)
        cell.location.font = UIFont.systemFont(ofSize: cell.location.font.pointSize)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return extractSectionKey(section: section)
    }
    
    func updateDisplayTasks() -> Void {
        func taskDictInsert(dict: inout [String: [Task]], task: Task) {
            let key = "0"
            if dict[key] == nil { dict[key] = [Task]() }
            dict[key]!.append(task)
        }
        
        self.displayTaskDict = [String: [Task]]()
        self.displayTaskDictComplete = [String: [Task]]()
        
        Tasks.getTasks(then: {tasks in
            for task in tasks {
                if task.completed == "false" { taskDictInsert(dict: &self.displayTaskDict, task: task) }
                else { taskDictInsert(dict: &self.displayTaskDictComplete, task: task) }
            }
            
            self.tableView.reloadData()
        })
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
            return "Pending"
        }
        else {
            return "Completed"
        }
    }
}













