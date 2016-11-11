//
//  MyIncompleteTasksViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 11/4/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class MyIncompleteTasksViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if firstTime() { firstTimeAlert() }
    }
    
    fileprivate func firstTime() -> Bool {
        return !UserDefaults().bool(forKey: "incompleteFirstTime")
    }
    
    fileprivate func firstTimeAlert() {
        UserDefaults().set(true, forKey: "incompleteFirstTime")
        
        let message = "Here, you can see all of your pending/incomplete tasks."
        let alert = UIAlertController(title: "View your pending tasks!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
