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
        let beacons = Beacons.sharedInstance.beacons
        
        TaskNotificationSender().notify(beacons[romeo]!)
    }
}
