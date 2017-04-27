//
//  MyHabitsTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class HabitList: UITableViewController {
    
    var habits: [(goal: String, tasks: [HabitAction])] = [(String, [HabitAction])]()
    
    var existingTaskToConstrain: HabitAction!
    var locationsForConstraining: [String]!
    
    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.title = "My habits and actions"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayHabits()
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
            return [loc] + tmp
        }
        
        if let tcvc = segue.destination as? HabitActionConstraintViewController {
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
extension HabitList {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return habits.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits[section].tasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return habits[section].goal
    }
    
    func capitalizeFirstLetter(_ string: String) -> String {
        let first = String(string.characters.prefix(1)).capitalized
        let other = String(string.characters.dropFirst())
        return first + other
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitActionCell", for: indexPath) as! HabitActionCell
        
        let h_action = habits[indexPath.section].tasks[indexPath.row]
    
        cell.h_action = h_action
        cell.tableViewController = self
        cell.taskName.text = h_action.name
        
        if (h_action.location == "unassigned") {
            cell.location.text = "unassigned"
        }
        else {
            cell.location.text = "At: \(h_action.location)"
        }
        
        
        if (h_action.beforeTime == "unassigned" || h_action.afterTime == "unassigned") {
            cell.timeRange.text = "unassigned"
        }
        else {
            func formatTime(_ taskTime: String) -> String {
                let parsed = Double(taskTime)!
                return NumberTimeFormatter().string(for: NSNumber(floatLiteral: parsed))!
            }
            
            cell.timeRange.text = "Active: \(formatTime(h_action.afterTime)) to \(formatTime(h_action.beforeTime))"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HabitActionCell
        
        let alert = UIAlertController(title: "Edit context?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            Beacons.shared.getAllLocations(handler: { locations in
                self.existingTaskToConstrain = cell.h_action
                self.locationsForConstraining = locations
                
                self.performSegue(withIdentifier: "constrainExistingTask", sender: self)
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateDisplayHabits() -> Void {
        Habits.getHabits(then: { habits in
            self.habits = habits
            self.tableView.reloadData()
        })
    }
}













