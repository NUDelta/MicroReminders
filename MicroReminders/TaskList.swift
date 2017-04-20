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
    
    var tasks: [Task] = [Task]()
    
    var existingTaskToConstrain: Task!
    var locationsForConstraining: [String]!
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.title = "Loading..."
        
        Tasks.getGoal(then: { goal in
            self.navigationItem.title = goal
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayTasks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // nothing now, like the stub tho
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        func prioritize(taskLocation loc: String, locations: [String]) -> [String] {
            if (loc == "unassigned") {
                return locations
            }
            var tmp = locations
            tmp.remove(at: locations.index(of: loc.lowercased())!)
            return [loc] + locations
        }
        
        if let tcvc = segue.destination as? TaskConstraintViewController {
            tcvc.pushHandler = {
                self.navigationController!.popViewController(animated: true)
            }
            
            if segue.identifier == "constrainExistingTask" {
                tcvc.existingTask = existingTaskToConstrain
                tcvc.locations = prioritize(
                    taskLocation: existingTaskToConstrain.location,
                    locations: locationsForConstraining
                ).map({ $0.capitalized })
            }
        }
    }
}

// TableView data source and delegate
extension TaskList {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func capitalizeFirstLetter(_ string: String) -> String {
        let first = String(string.characters.prefix(1)).capitalized
        let other = String(string.characters.dropFirst())
        return first + other
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let task = tasks[indexPath.row]
    
        cell.task = task
        cell.tableViewController = self
        cell.taskName.text = task.name
        
        if (task.location == "unassigned") {
            cell.location.text = "unassigned"
        }
        else {
            cell.location.text = "At: \(task.location)"
        }
        
        
        if (task.beforeTime == "unassigned" || task.afterTime == "unassigned") {
            cell.timeRange.text = "unassigned"
        }
        else {
            func formatTime(_ taskTime: String) -> String {
                let parsed = Double(taskTime)!
                return NumberTimeFormatter().string(for: NSNumber(floatLiteral: parsed))!
            }
            
            cell.timeRange.text = "Active: \(formatTime(task.afterTime)) to \(formatTime(task.beforeTime))"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        
        let alert = UIAlertController(title: "Edit context?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            Beacons.shared.getAllLocations(handler: { locations in
                self.existingTaskToConstrain = cell.task
                self.locationsForConstraining = locations
                
                self.performSegue(withIdentifier: "constrainExistingTask", sender: self)
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateDisplayTasks() -> Void {
        Tasks.getTasks(then: { tasks in
            self.tasks = tasks
            self.tableView.reloadData()
        })
    }
}













