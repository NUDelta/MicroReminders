//
//  Tasks.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/16/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class Tasks {
    static let sharedInstance = Tasks()
    private let tasksRef: FIRDatabaseReference!
    private let prepopRef: FIRDatabaseReference!
    
    var taskListeners = [String: (() -> Void)]()
    
    var tasks = [Task]() {
        didSet {
            goals = goalsFromTasks(tasks: tasks)
            taskListeners.forEach({ $1() })
        }
    }
    
    let otherGoal: Goal = ("Other", [Task]())
    private var goals: [Goal] = [Goal]() {
        didSet {
            nonEmptyGoals = goals.filter({ pendingTasksForGoal(goal: $0) != 0 })
            emptyGoals = [otherGoal] + goals.filter({ pendingTasksForGoal(goal: $0) == 0 })
        }
    }
    var nonEmptyGoals: [Goal] = [Goal]()
    var emptyGoals: [Goal] = [Goal]()
    
    private init() {
        tasksRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.current.identifierForVendor!.uuidString)")
        prepopRef = FIRDatabase.database().reference().child("Tasks/Prepopulated_Goals")
        
        tasksRef.observe(.value, with: {snapshot in
            self.tasks = self.fillTaskList(snapshot)
            
            if self.tasks.isEmpty {
                self.prepopRef.observeSingleEvent(of: .value, with:{ snapshot in
                    let prepopulated = self.fillTaskList(snapshot)
                    
                    prepopulated.forEach({ task in
                        task.pushToFirebase(handler: nil)
                    })
                })
            }
        })
    }
    
    private func fillTaskList(_ snapshot: FIRDataSnapshot) -> [Task] {
        var taskList = [Task]()
        let taskJSON = snapshot.value as? [String: [String: String]]
        
        if taskJSON != nil {
            for (_id, taskData) in taskJSON! {
                let task = Task(
                    _id,
                    name: taskData["task"]!,
                    goal: taskData["goal"]!,
                    order: taskData["order"]!,
                    location: taskData["location"]!,
                    beforeTime: taskData["beforeTime"]!,
                    afterTime: taskData["afterTime"]!,
                    completed: taskData["completed"]!,
                    lastSnoozed: taskData["lastSnoozed"]!
                )
                
                taskList.append(task)
            }
        }
        
        return taskList
    }
    
    fileprivate func goalsFromTasks(tasks: [Task]) -> [Goal] {
        let goals = tasks
            .map({ (task) -> (String, Task) in return (task.goal, task) })
            .reduce([String: [Task]]()) { acc, t in
                var tmp = acc
                if (acc[t.0] != nil) {
                    tmp[t.0]!.append(t.1)
                }
                else {
                    tmp[t.0] = [t.1]
                }
                return tmp
            }
            .map({ (goal, taskList) in (goal, taskList) })
        
        return goals
    }
    
    func goalForTitle(title: String) -> Goal {
        return (nonEmptyGoals + emptyGoals).filter({ $0.0 == title }).first!
    }
    
    func pendingTasksForGoal(goal: Goal) -> Int {
        return goal.1.filter({ $0.completed == "false" }).count
    }
}















