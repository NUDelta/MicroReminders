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

            Habits.getHabits(then: { habits in
                
                let sensor = BackgroundSensor()
                
                /* 1) Isolate the actions that are remindable right now */
                let immediates = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker
                        .immediatelyAvailableUponRegionChange(habit.1, dir: .enter, reg: region)
                }
                
                /* 2) Of the immediates, pick one and notify */
//                self.notify(immediates)
                
                /* 3) Find tasks with a plug event */
                let immOnPlug = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker.hasPlug(habit.1, at: region)
                }
                
                /* Start background monitoring for plug events */
//                sensor.waitForPlug(for: immOnPlug, handler: self.notify)
            })
        })
    }
    
    func exited(region: UInt16) {
        Beacons.shared.getBeaconLocation(forKey: region, handler: { region in
            Logger.logRegionInteraction(region: region, way: .exited)
            
//            self.sensor.stop()
            
            Habits.getHabits(then: { habits in
                
                /* 1) Isolate the actions that are remindable right now */
                let immediates = habits.reduce([HabitAction]()) { acc, habit in
                    return acc + self.checker
                        .immediatelyAvailableUponRegionChange(habit.1, dir: .exit, reg: region)
                }
                
                /* 2) Of the immediates, pick one and notify */
                self.notify(immediates)
            })
        
        })
    }
}

/** Utility functions */
extension NotificationBrain {
    
    /** Send a notification for an h_action */
    fileprivate func notify(_ h_action: HabitAction) {
        self.notifier.sendNotificationNow(h_action)
    }
    
    /** Send a notification for one of an array of h_actions */
    fileprivate func notify(_ h_actions: [HabitAction]) {
        if let one = self.pickRandom(h_actions: h_actions) {
            self.notifier.sendNotificationNow(one)
        }
    }
    
    /** Pick a random h_action */
    fileprivate func pickRandom(h_actions: [HabitAction]) -> HabitAction? {
        if (h_actions.isEmpty) { return nil }
        
        let randomInd = Int(arc4random()) % h_actions.count
        return h_actions[randomInd]
    }
}















