//
//  BackgroundTasker.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/30/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import NotificationCenter

/** Context sense in the background */
class BackgroundSensor {
    
    fileprivate var bgTimer: Timer? = Timer()
    fileprivate var delayTimers: [HabitAction: Timer] = [:]
    
    
    
    /*-------------------------------------------------------------*/
    /* Wait for location delays */
    func startLocationDelayTimers(for h_actions: [HabitAction], handler: @escaping (HabitAction) -> Void) {
        
        h_actions.forEach({ ha in
            let delay = Double(ha.context.location.delay)
            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in handler(ha) })
            
            self.delayTimers.updateValue(timer, forKey: ha)
        })
        
        /* Keep the app alive to wait */
        startBGTask()
    }
    
    
    
    /*-------------------------------------------------------------*/
    /* Wait to respond immediately to plug events */
    fileprivate var waitingForPlugImm: [HabitAction] = []
    fileprivate var immPlugHandler: ([HabitAction]) -> Void = {_ in }
    func waitForPlug(for h_actions: [HabitAction], handler: @escaping ([HabitAction]) -> Void) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        self.waitingForPlugImm = h_actions
        self.immPlugHandler = handler
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(handlePlugEventImm), name: .UIDeviceBatteryStateDidChange, object: nil)
        
        /* Keep the app alive to listen */
        self.startBGTask()
    }
    
    @objc fileprivate func handlePlugEventImm() {
        let state = UIDevice.current.batteryState
        var avail: [HabitAction] = []
        
        switch (state) {
        case .charging:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .plug })
            break
        case .unplugged:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .unplug })
            break
        default:
            break
        }
        
        self.immPlugHandler(avail)
    }
    
    
    
    /*-------------------------------------------------------------*/
    /* Wait to respond after a delay to plug events */
    fileprivate var waitingForPlugDel: [HabitAction] = []
    fileprivate var delPlugHandler: (HabitAction) -> Void = {_ in }
    func waitForPlugAndDelay(for h_actions: [HabitAction], handler: @escaping (HabitAction) -> Void) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        self.waitingForPlugDel = h_actions
        self.delPlugHandler = handler
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(handlePlugEventDel), name: .UIDeviceBatteryStateDidChange, object: nil)
        
        /* Keep the app alive to listen and wait */
        self.startBGTask()
    }
    
    @objc fileprivate func handlePlugEventDel() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState
        var avail: [HabitAction] = []
        
        switch (state) {
        case .charging:
            avail = self.waitingForPlugDel.filter({ ha in ha.context.plug.plug_unplug == .plug })
            break
        case .unplugged:
            avail = self.waitingForPlugDel.filter({ ha in ha.context.plug.plug_unplug == .unplug })
            break
        default:
            break
        }
        
        self.startDelayTimerAfterPlug(for: avail)
    }
    
    fileprivate func startDelayTimerAfterPlug(for h_actions: [HabitAction]) {
        h_actions.forEach({ ha in
            let delay = Double(ha.context.plug.delay)
            
            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in self.delPlugHandler(ha) })
            self.delayTimers.updateValue(timer, forKey: ha)
        })
    }
}

/** Keep the app alive in the background indefinitely */
extension BackgroundSensor {
    
    /* Kill the background task */
    func stop() {
        print("Killing background task...")
        
        if (bgTimer != nil) {
            bgTimer!.invalidate()
            bgTimer = nil
        }
        
        cleanup()
    }
    
    fileprivate func cleanup() {
        /* Invalidate delay timers */
        self.delayTimers.forEach({ pair in
            pair.value.invalidate()
        })
        self.delayTimers.removeAll()
        
        /* Remove battery state observers */
        NotificationCenter.default.removeObserver(self, name: .UIDeviceBatteryStateDidChange, object: nil)
    }
    
    @objc fileprivate func restart() {
        print("Restarted background timer...")
        
        if (bgTimer != nil) {
            bgTimer!.invalidate()
            bgTimer = nil
        }
        
        startBGTask()
    }
    
    fileprivate func startBGTask() {
        print("Started background sensing...")
        
        if (bgTimer != nil) { // If we already have a background task running
            return
        }
        
        let bgTask = BackgroundTaskManager.shared()
        bgTask?.beginNewBackgroundTask()
        
        // Invalidate and recreate the background task, to give it new life
        let intervalLength = 60.0
        bgTimer = Timer.scheduledTimer(timeInterval: intervalLength, target: self, selector: #selector(self.restart), userInfo: nil, repeats: false)
    }
}
