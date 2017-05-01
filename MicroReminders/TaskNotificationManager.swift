//
//  Notify.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/28/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class TaskInteractionManager {
    
    fileprivate let myId = UserConfig.shared.userKey
    fileprivate let logger = Logger()
    
}

/** Send h_action notifications */
class TaskNotificationSender: TaskInteractionManager {
    fileprivate let scheduler = TaskScheduler()
    
    /** Select and notify for tasks for a given location, at the current time */
    fileprivate func notify(_ location: String) {

        /*
        Habits.getHabits(then: {tasks in
            let candidatesForNotification = tasks.filter({ self.canNotify(for: $0, location: location) })
            
            if (!candidatesForNotification.isEmpty) {
                let taskToNotify = self.scheduler.pickTaskToNotify(tasks: candidatesForNotification)
                self.sendNotification(taskToNotify)
            }
        })
        */
        
    }
    
    /** Handle entering region */
    func entered(region regionInt: UInt16) {
        Beacons.shared.getBeaconLocation(forKey: regionInt, handler: { location in
            
        })
    }
    
    /** Handle exiting region */
    func exited(region regionInt: UInt16) {
        Beacons.shared.getExitTime(forKey: regionInt, handler: { then in
            /*
             This is to ensure that we only reset the exit time if the previous region event was an
             entrance, protecting against sequential exit events.
             */
            if (then.timeIntervalSinceNow > Double(Int.max/2)) {
                Beacons.shared.setExitTime(forKey: regionInt, to: Date())
            }
        })
    }
    
}


/** Pick the next h_action to notify */
fileprivate class TaskScheduler {
    
    /** Pick a random h_action */
    fileprivate func pickRandom(tasks: [HabitAction]) -> HabitAction {
        let randomInd = Int(arc4random()) % tasks.count
        return tasks[randomInd]
    }
    
    /** Pick a scheduling policy, and notify for that h_action */
    fileprivate func pickTaskToNotify(tasks: [HabitAction]) -> HabitAction {
        return pickRandom(tasks: tasks)
    }
}










