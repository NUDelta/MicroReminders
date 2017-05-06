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

    fileprivate var delayTimers: [HabitAction: Timer] = [:]
    
    
    
    /*-------------------------------------------------------------*/
    /* Wait for location delays */
    func startLocationDelayTimers(for h_actions: [HabitAction], handler: @escaping (HabitAction) -> Void) {
        
        h_actions.forEach({ ha in
            let delay = ha.context.location.delay * 60
            if (self.delayTimers[ha] == nil) {
                let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in
                    self.delayTimers.removeValue(forKey: ha)
                    handler(ha)
                })
                self.delayTimers.updateValue(timer, forKey: ha)
            }
        })
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
    }
    
    @objc fileprivate func handlePlugEventImm() {
        let state = UIDevice.current.batteryState
        var avail: [HabitAction] = []
        
        switch (state) {
        case .charging:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .plug })
            break
        case .full:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .plug })
            break
        case .unplugged:
            avail = self.waitingForPlugImm.filter({ ha in ha.context.plug.plug_unplug == .unplug })
            break
        case .unknown:
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
            let delay = Double(ha.context.plug.delay) * 60.0
            
            if (self.delayTimers[ha] == nil) {
                let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in
                    self.delayTimers.removeValue(forKey: ha)
                    self.delPlugHandler(ha)
                })
                self.delayTimers.updateValue(timer, forKey: ha)
            }
        })
    }
}
