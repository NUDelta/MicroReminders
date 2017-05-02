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
    var sensors: [String: BackgroundSensor] = [:]
    
    /** Handles entering a region */
    func entered(region: UInt16) {
        Beacons.shared.getBeaconLocation(forKey: region, handler: { region in
            Logger.logRegionInteraction(region: region, way: .entered)
            
            // If we are not already sensing for this region (i.e. two enter events in a row)
            if (self.sensors[region] == nil) {
                
                let sensor = BackgroundSensor()
                self.sensors.updateValue(sensor, forKey: region)
                
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
                    self.notify(immediates)
                    
                    /* 3) Find tasks with delays */
                    let locDelay = habits.reduce([HabitAction]()) { acc, habit in
                        return acc + self.checker.hasLocationDelay(habit.1, for: region)
                    }
                    
                    let immOnPlug = habits.reduce([HabitAction]()) { acc, habit in
                        return acc + self.checker.hasPlug(habit.1, at: region, withDelay: false)
                    }
                    
                    let plugDelay = habits.reduce([HabitAction]()) { acc, habit in
                        return acc + self.checker.hasPlug(habit.1, at: region, withDelay: true)
                    }
                    
                    /* Start background monitoring for the delays */
                    sensor.startLocationDelayTimers(for: locDelay, handler: self.notify)
                    sensor.waitForPlug(for: immOnPlug, handler: self.notify)
                    sensor.waitForPlugAndDelay(for: plugDelay, handler: self.notify)
                })
            }
        })
    }
    
    func exited(region: UInt16) {
        Beacons.shared.getBeaconLocation(forKey: region, handler: { region in
            Logger.logRegionInteraction(region: region, way: .exited)
            
            if let sensor = self.sensors[region] {
                /** Steps:
                 
                 1) Kill any background tasks dependent on us being in the region
                 2) Find any actions immediately available after exiting
                 3) Pick one (there should only be one) and send a notification
                 
                 */
                
                
                /* 1) Kill any background tasks for the region */
                sensor.stop()
                self.sensors.removeValue(forKey: region)
                
                Habits.getHabits(then: { habits in
                    
                    /* 2) Isolate the actions that are remindable right now */
                    let immediates = habits.reduce([HabitAction]()) { acc, habit in
                        return acc + self.checker
                            .immediatelyAvailableUponRegionChange(habit.1, dir: .exit, reg: region)
                    }
                    
                    /* 3) Of the immediates, pick one and notify */
                    self.notify(immediates)
                })
            }
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















