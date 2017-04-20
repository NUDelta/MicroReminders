//
//  mockViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/26/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

class MockViewController: UIViewController {
    @IBAction func mockPressed(_ sender: Any) {
        let romeo: UInt16 = 59582
        Beacons.shared.getExitTime(forKey: romeo, handler: { then in
            UserConfig.getThreshold(handler: { threshold in
                /*
                 This should never be relevant - we should only ever enter after exiting. What that means
                 is that we should check this value before it is set here, and set it again in "didExitRegion"
                 before we check it next. However, since the beacons are buggy, and I'm concerned about
                 sequential "didEnterRegion" events, I'm leaving this in here.
                 */
                Beacons.shared.setExitTime(forKey: romeo, to: Date(timeIntervalSinceNow: Double(Int.max)))
                
                if (Date().timeIntervalSince(then) > 60.0*threshold) {
                    TaskNotificationSender().entered(region: romeo)
                }
            })
        })
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        let regionInt: UInt16 = 59582
        
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
