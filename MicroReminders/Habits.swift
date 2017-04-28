//
//  Habits.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/16/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class Habits {
    private static let sharedInstance = Habits()
    private static let userKey = UserConfig.shared.userKey
    private static let habitRef = FIRDatabase.database().reference().child("Habits/\(userKey)")
    
    var habits: [(String, [HabitAction])]?
    
    static func getHabits(then handler: @escaping ([(String, [HabitAction])]) -> Void) {
        if let habits = Habits.sharedInstance.habits {
            handler(habits)
        }
        else {
            Habits.sharedInstance.queryHabits(then: handler)
        }
    }
    
    private init() {
        listenToHabits()
    }
    
    private func listenToHabits() {
        Habits.habitRef.observe(.value, with: {snapshot in
            self.habits = Habits.extractHabits(snapshot)
        })
    }
    
    private func queryHabits(then handler: @escaping ([(String, [HabitAction])]) -> Void) {
        Habits.habitRef.observeSingleEvent(of: .value, with: {snapshot in
            self.habits = Habits.extractHabits(snapshot)
            handler(self.habits!)
        })
    }
    
    private static func extractHabits(_ snapshot: FIRDataSnapshot) -> [(String, [HabitAction])] {
        let habitJSON = snapshot.value as? [String: [String: [String: AnyObject]]]
        
        var _habits = [(String, [HabitAction])]()
        
        if habitJSON != nil {
            for (goal, tasks) in habitJSON! {
                var taskList = [HabitAction]()
                
                for (_id, taskData) in tasks {
                    let h_action = HabitAction(
                        _id,
                        name: taskData["task"]!,
                        location: taskData["location"]!,
                        beforeTime: taskData["beforeTime"]!,
                        afterTime: taskData["afterTime"]!,
                        completed: taskData["completed"]!,
                        lastSnoozed: taskData["lastSnoozed"]!
                    )
                    
                    taskList.append(h_action)
                }
                
                _habits.append((goal, taskList))
            }
        }
        
        return _habits
    }
}















