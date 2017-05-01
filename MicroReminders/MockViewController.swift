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
        print("This will be different...")
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        print("This will be different...")
    }
}
