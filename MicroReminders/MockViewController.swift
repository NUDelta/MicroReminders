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
        Beacons.shared.okayToNotify(for: zelda, handler: { ok in
            if ok {
                TaskNotificationSender().entered(region: self.zelda)
            }
        })
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        Beacons.shared.okayToNotify(for: zelda, handler: { ok in
            
        })
    }
}
