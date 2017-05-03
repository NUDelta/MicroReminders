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
        queryHabits(then: {_ in print("Initialized habits...") })
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
            for (habit, actions) in habitJSON! {
                var h_actions = [HabitAction]()
                
                for (description, context) in actions {
                    /* Location context */
                    let loc = context["location"]! as! [String: Any]
                    let lc = LocationContext(
                        region: loc["region_name"] as! String,
                        enter_exit: (loc["enter_exit"] as! Int) == 1 ? .enter : .exit,
                        delay: loc["delay"] as! Double
                    )
                    
                    /* Plug context */
                    let plug = context["plug"] as! [String: Double]
                    let pc = PlugContext(
                        plug_unplug: (plug["plug_unplug"] == 1) ? .plug : (plug["plug_unplug"] == -1) ? .unplug : .ignore,
                        delay: plug["delay"]!
                    )
                    
                    /* Time of day context */
                    let time = context["time_of_day"] as! [String: Int]
                    let tod = TimeOfDayContext(
                        before: time["before"]!,
                        after: time["after"]!
                    )
                    
                    /* Previous interaction context */
                    let _prev = context["prev_interactions"] as! [String: [String: Double]]
                    
                    let _acc = _prev["accepted"]!
                    let acc = ReminderInteraction(type: .accepted, last: Int(_acc["last"]!), thresh_since_last: _acc["thresh_since_last"]!)
                    
                    let _dec = _prev["declined"]!
                    let dec = ReminderInteraction(type: .declined, last: Int(_dec["last"]!), thresh_since_last: _dec["thresh_since_last"]!)
                    
                    let _thr = _prev["thrown"]!
                    let thr = ReminderInteraction(type: .thrown, last: Int(_thr["last"]!), thresh_since_last: _thr["thresh_since_last"]!)
                    
                    let prev = PreviousInteractionsContext(accepted: acc, declined: dec, thrown: thr)
                    
                    /* Put it all together */
                    let context = Context(location: lc, plug: pc, time: tod, prev: prev)
                    let h_action = HabitAction(description, habit: habit, context: context)
                    
                    h_actions.append(h_action)
                }
                
                _habits.append((habit, h_actions))
            }
        }
        
        return _habits
    }
}















