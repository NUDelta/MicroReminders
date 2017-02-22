//
//  MyTasksTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class GoalTaskList: UITableViewController {
    
    var goal: Goal!
    var displayTaskDict = [String: [Task]]()
    var displayTaskDictComplete = [String: [Task]]()
    
    var unassignedTaskToConstrain: Task!
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.title = goal!.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Tasks.sharedInstance.taskListeners
            .updateValue(initGoal, forKey: "updateGoalFor\(goal!.0)")
        
        initGoal()
    }
    
    func initGoal() {
        self.goal = Tasks.sharedInstance.goalForTitle(title: self.goal!.0)
        self.updateDisplayTasks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Tasks.sharedInstance.taskListeners.removeValue(forKey: "updateTasksFor\(goal!.0)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ctcvc = segue.destination as? CustomTaskConstraintViewController {
            ctcvc.goal = goal
            ctcvc.pushHandler = {
                self.navigationController!.popViewController(animated: true)
            }
            
            if segue.identifier == "constrainUnassignedTask" {
                ctcvc.existingTask = unassignedTaskToConstrain
            }
        }
    }
}

// TableView data source and delegate
extension GoalTaskList {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalTask", for: indexPath) as! GoalTask
        
        let task = extractSection(section: indexPath.section)[indexPath.row]
        
        if (task.location == "no location") {
            cell.backgroundColor = UIColor.white
            cell.taskName.text = task.name
            cell.active = .unassigned
            cell.button.setTitle("＋", for: .normal)
        }
        else if (indexPath.section < displayTaskDict.keys.count) {
            cell.backgroundColor = UIColor.white
            cell.taskName.text = task.name
            cell.active = .active
            cell.button.setTitle("☐", for: .normal)
        }
        else {
            cell.backgroundColor = UIColor.lightGray
            cell.taskName.text = task.name
            cell.active = .done
            cell.button.setTitle("☑︎", for: .normal)
        }
        cell.task = task
        cell.tableViewController = self
        cell.time.text = "⏳ \(task.length)"
        cell.location.text = "\(capitalizeFirstLetter(task.location))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return extractSectionKey(section: section)
    }
    
    func updateDisplayTasks() -> Void {
        func taskDictInsert(dict: inout [String: [Task]], task: Task) {
            let key = task.goal
            if dict[key] == nil { dict[key] = [Task]() }
            dict[key]!.append(task)
        }
        
        func taskDictSort(dict: inout [String: [Task]]) {
            for (category, tasklist) in dict {
                let sorted = tasklist.sorted(by: { (task1, task2) in task1.order < task2.order })
                dict[category] = sorted
            }
        }
        
        self.displayTaskDict = [String: [Task]]()
        self.displayTaskDictComplete = [String: [Task]]()
        
        for task in goal.1 {
            if task.completed == "false" { taskDictInsert(dict: &self.displayTaskDict, task: task) }
            else { taskDictInsert(dict: &self.displayTaskDictComplete, task: task) }
        }
        
        taskDictSort(dict: &self.displayTaskDict)
        taskDictSort(dict: &self.displayTaskDictComplete)
        
        self.tableView.reloadData()
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













