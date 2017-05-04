//
//  BackgroundTasker.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/30/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import NotificationCenter
import Firebase

/** Context sense in the background */
class BackgroundSensor {
    
    fileprivate var bgTimer: Timer? = nil
    
    
    
    /*-------------------------------------------------------------*/
    /* Wait to respond immediately to plug events */
    fileprivate var waitingForPlugImm: [HabitAction] = []
    fileprivate var immPlugHandler: ([HabitAction]) -> Void = {_ in }
    func waitForPlug(for h_actions: [HabitAction], handler: @escaping ([HabitAction]) -> Void) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        self.waitingForPlugImm = h_actions
        self.immPlugHandler = handler
        
        print("Listening for battery state changes...")
        NotificationCenter.default
            .addObserver(self, selector: #selector(handlePlugEventImm), name: .UIDeviceBatteryStateDidChange, object: nil)
        
        /* Keep the app alive to listen */
//        self.startBGTask()
    }
    
    @objc fileprivate func handlePlugEventImm() {
        let state = UIDevice.current.batteryState
        var avail: [HabitAction]
        
        switch (state) {
        case .full:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .plug })
            break
        case .charging:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .plug })
            break
        case .unplugged:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .unplug })
            break
        default:
            avail = []
            break
        }
        
        self.immPlugHandler(avail)
    }
}

/** Keep the app alive in the background indefinitely */
extension BackgroundSensor {
    
    func stopBGTask() {
        
        if (bgTimer != nil) {
            bgTimer!.invalidate()
            bgTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: .UIDeviceBatteryStateDidChange, object: nil)
    }
    
    @objc fileprivate func restart() {
        print("Restarted background timer...")
        
        FIRDatabase.database().reference().child("log").child("\(Int(Date().timeIntervalSince1970))").setValue("hey")
        
        if (bgTimer != nil) {
            bgTimer!.invalidate()
            bgTimer = nil
        }
        
        startBGTask()
    }
    
    @objc func startBGTask() {
        print("Started background sensing...")
        
        if (bgTimer != nil) { // If we already have a background task running
            return
        }
        
        let bgTask = BackgroundTaskManager.shared()
        bgTask?.beginNewBackgroundTask()
        
        let intervalLength = 10.0
        
        // Invalidate and recreate the background task, to give it new life
        bgTimer = Timer.scheduledTimer(timeInterval: intervalLength, target: self, selector: #selector(self.restart), userInfo: nil, repeats: false)
    }
}
