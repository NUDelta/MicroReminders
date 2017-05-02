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
        cell.taskName.text = h_action.description
        
        cell.location.text = "Haven't finished this yet"
        
        cell.timeRange.text = "Probably use the NumberTimeFormatter for this eventually"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No response to taps
    }
    
    func updateDisplayHabits() -> Void {
        Habits.getHabits(then: { habits in
            self.habits = habits
            self.tableView.reloadData()
        })
    }
}













