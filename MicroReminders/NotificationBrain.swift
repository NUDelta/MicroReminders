//
//  NotificationBrain.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/30/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

/** Decides what to do when a region is entered - the entry point for notifying */
class NotificationBrain {
    let checker = ContextChecker()
    let notifier = NotificationHandler()
    
    /** Handles entering a region */
    func entered(region: UInt16) {
        Beacons.shared.getBeaconLocation(forKey: region, handler: { region in
            Logger.logRegionInteraction(region: region, way: .entered)
            
            /** Steps:
             
             1) Isolate the actions that are immediately remindable
             
             2) Of the immediately available, pick one and notify
             
             3) Find tasks for the location with delays (time/plug)
             
             4) Start background monitoring for the delays
             
             */
            
            Habits.getHabits(then: { habits in
                
                /* 1) Isolate the actions that are remindable right now */
                let immediates = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker
                        .immediatelyAvailableUponRegionChange(habit.1, dir: .enter, reg: region)
                }
                
                /* 2) Of the immediates, pick one and notify */
                if let immediate = self.pickRandom(h_actions: immediates) {
                    self.notifier.sendNotificationNow(immediate)
                }
                
                /* 3) Start background monitoring for the delays */
                let locDelay = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker
                        .hasLocationDelay(habit.1, for: region)
                }
                
                let immOnPlug = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker.hasPlug(habit.1, at: region, withDelay: false)
                }
                
                let plugDelay = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker.hasPlug(habit.1, at: region, withDelay: true)
                }
                
                
            })
        })
    }
    
    func exited(region: UInt16) {
        Beacons.shared.getBeaconLocation(forKey: region, handler: { region in
            Logger.logRegionInteraction(region: region, way: .exited)
            
            /** Steps:
             
             1) Find any actions immediately available after exiting
             
             2) Pic on (there should only be one) and send a notification
             
             3) Kill any background tasks dependent on us being in the region
             
             */
            
            Habits.getHabits(then: { habits in
                
                /* 1) Isolate the actions that are remindable right now */
                let immediates = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker
                        .immediatelyAvailableUponRegionChange(habit.1, dir: .exit, reg: region)
                }
                
                /* 2) Of the immediates, pick one and notify */
                if let immediate = self.pickRandom(h_actions: immediates) {
                    self.notifier.sendNotificationNow(immediate)
                }
            })
        })
    }
}

/** Utility functions */
extension NotificationBrain {
    
    /** Pick a random h_action */
    fileprivate func pickRandom(h_actions: [HabitAction]) -> HabitAction? {
        if (h_actions.isEmpty) { return nil }
        
        let randomInd = Int(arc4random()) % h_actions.count
        return h_actions[randomInd]
    }
}















