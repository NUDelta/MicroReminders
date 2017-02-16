//
//  MyTasksTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class MyTasksTableViewController: UITableViewController {
    var myTaskRef: FIRDatabaseReference!
    
    var displayTaskList = [Task]()
    var displayTaskDict = [String: [Task]]()
    var displayTaskDictComplete = [String: [Task]]()
    
    var loadingIndicator: UIActivityIndicatorView! = nil
    
    var tappedCell = -1
    
    let myDarkGrey = UIColor(colorLiteralRed: 204.0/255, green: 204.0/255, blue: 204.0/255, alpha: 1)
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        myTaskRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadingIndicator = activityIndicator()
        self.view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    func activityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        return indicator
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
    
    func capitalizeFirstLetter(_ string: String) -> String {
        let first = String(string.characters.prefix(1)).capitalized
        let other = String(string.characters.dropFirst())
        return first + other
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTasksTableCell", for: indexPath) as! MyTasksTableCell
        
        let task = extractSection(section: indexPath.section)[indexPath.row]
        
        if (indexPath.section < displayTaskDict.keys.count) {
            cell.backgroundColor = UIColor.white
            cell.taskName.text = task.name
            cell.active = true
            cell.button.setTitle("☐", for: .normal)
        }
        else {
            cell.backgroundColor = myDarkGrey
            cell.taskName.text = task.name
            cell.active = false
            cell.button.setTitle("☑︎", for: .normal)
        }
        cell.task = task
        cell.tableViewController = self
        cell.time.text = "⏳ \(task.length)"
        cell.location.text = "[\(capitalizeFirstLetter(task.location))]"
        
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
        
        self.displayTaskList = Tasks.sharedInstance.tasks
        self.displayTaskDict = [String: [Task]]()
        self.displayTaskDictComplete = [String: [Task]]()
        
        for task in self.displayTaskList {
            if task.completed == "false" { taskDictInsert(dict: &self.displayTaskDict, task: task) }
            else { taskDictInsert(dict: &self.displayTaskDictComplete, task: task) }
        }
        
        taskDictSort(dict: &self.displayTaskDict)
        taskDictSort(dict: &self.displayTaskDictComplete)
        
        self.loadingIndicator.stopAnimating()
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
            return Array(displayTaskDict.keys).sorted(by: { (cat1, cat2) in cat1 < cat2 })[section]
        }
        else {
            let mod = section - incompleteCategoryCount
            return Array(displayTaskDictComplete.keys).sorted(by: { (cat1, cat2) in cat1 < cat2 })[mod] + " (complete)"
        }
    }
}













