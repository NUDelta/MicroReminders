//
//  MyTaskViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/22/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import UIKit

class MyCompleteTasksViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if firstTime() { firstTimeAlert() }
    }
    
    fileprivate func firstTime() -> Bool {
        return !UserDefaults().bool(forKey: "completeFirstTime")
    }
    
    fileprivate func firstTimeAlert() {
        UserDefaults().set(true, forKey: "completeFirstTime")
        
        let message = "Here, you can see all of your finished tasks."
        let alert = UIAlertController(title: "View your completed tasks!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
