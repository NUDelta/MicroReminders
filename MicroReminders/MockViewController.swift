//
//  mockViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/26/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

class MockViewController: UIViewController {
    let zelda: UInt16 = 56913
    
    @IBAction func mockPressed(_ sender: Any) {
        Beacons.shared.getExitTime(forKey: zelda, handler: { then in
            UserConfig.shared.getThreshold(handler: { threshold in
                /*
                 This should never be relevant - we should only ever enter after exiting. What that means
                 is that we should check this value before it is set here, and set it again in "didExitRegion"
                 before we check it next. However, since the beacons are buggy, and I'm concerned about
                 sequential "didEnterRegion" events, I'm leaving this in here.
                 */
                Beacons.shared.setExitTime(forKey: self.zelda, to: Date(timeIntervalSinceNow: Double(Int.max)))
                
                if (Date().timeIntervalSince(then) > 60.0*threshold) {
                    TaskNotificationSender().entered(region: self.zelda)
                }
            })
        })
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        Beacons.shared.getExitTime(forKey: zelda, handler: { then in
            /*
             This is to ensure that we only reset the exit time if the previous region event was an
             entrance, protecting against sequential exit events.
             */
            if (then.timeIntervalSinceNow > Double(Int.max/2)) {
                Beacons.shared.setExitTime(forKey: self.zelda, to: Date())
            }
        })
    }
}
