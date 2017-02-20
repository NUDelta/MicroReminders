//
//  TaskLandingPageTableTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/14/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class AddTaskTableViewController: UITableViewController {
    var prepopTaskList = [Task]()
    var myTaskList = [Task]()
    var displayTaskList = [Task]()
    
    var tappedCell: Task!
    
    var taskCategory: String! = nil
    
    let myLightGrey = UIColor(colorLiteralRed: 217.0/255, green: 217.0/255, blue: 217.0/255, alpha: 1)
    let myDarkGrey = UIColor(colorLiteralRed: 204.0/255, green: 204.0/255, blue: 204.0/255, alpha: 1)
    
    var loadingIndicator: UIActivityIndicatorView! = nil
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func updateDisplayTasks() -> Void {
        self.prepopTaskList = Tasks.sharedInstance.prepopulated
        self.myTaskList = Tasks.sharedInstance.tasks
        
        let myTaskIds = self.myTaskList.filter({ task in task.completed == "false"}).map({ task in task._id })
        self.displayTaskList = self.prepopTaskList.filter({ task in
            !myTaskIds.contains(task._id) && task.category == self.taskCategory!
        })
        
        self.displayTaskList.sort(by: { (task1, task2) in task1.subcategory > task2.subcategory })
        
        self.loadingIndicator.stopAnimating()
        self.tableView.reloadData()
    }
    
    // Table display
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTaskList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddTaskTableCell", for: indexPath) as! AddTaskTableCell
        
        let task = displayTaskList[indexPath.row]
        cell.taskName.text = task.name
        cell.time.text = "⏳ \(task.length)"
        cell.task = task
        cell.tableViewController = self
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = myLightGrey
        }
        else {
            cell.backgroundColor = myDarkGrey
        }
        
        return cell
    }
    
    // Table interaction
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tappedCell = displayTaskList[indexPath.row]
    }
}




















