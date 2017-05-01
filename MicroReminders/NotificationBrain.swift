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
    func entered(region: String) {
        /** Steps:
         
         1) Isolate the actions that are remindable right now
         
         2) Pick one (there should only really be one for right now, and maybe some with delays)
         
         3) If it's an immediate one, send a notification.
         
         4) If it's a delayed one, start a background sensor.
         
        */
    }
    
    func exited(region: String) {
        /** Steps:
         
         1) Kill any background tasks dependent on us being in the region
         
         2) Find any actions with applicable exit context.
         
         3) Pick on (there should only be one) and send a notification.
         
         */
    }
}
