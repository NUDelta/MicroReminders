//
//  MockEnterViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 11/27/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class MockEnterViewController: UIViewController {
    
    let beacons = Beacons.sharedInstance.beacons
    var beaconExitTimes = Beacons.sharedInstance.beaconExitTimes
    
    @IBAction func mockEnterKitchen(_ sender: UIButton) {
        let regionInt: UInt16 = 59582
        
        let threshold: Double = 3
        let then = beaconExitTimes[regionInt]!
        
        beaconExitTimes[regionInt] = Date(timeIntervalSinceNow: Double(Int.max))
        
        if (Date().timeIntervalSince(then) > threshold) {
            TaskNotificationSender().notify(beacons[regionInt]!)
        }
    }
    
    @IBAction func mockExitKitchen(_ sender: UIButton) {
        let regionInt: UInt16 = 59582
        if (beaconExitTimes[regionInt]!.timeIntervalSinceNow > Double(Int.max/2)) {
            beaconExitTimes[regionInt] = Date()
        }
    }
}
