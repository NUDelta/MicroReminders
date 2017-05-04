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
    // Not anymore
}
