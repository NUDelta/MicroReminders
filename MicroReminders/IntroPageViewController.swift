//
//  IntroPageViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 11/9/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class IntroPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !firstTime() { segue() }
    }
    
    fileprivate func firstTime() -> Bool {
        return !UserDefaults().bool(forKey: "getStarted")
    }
    
    @IBAction func getStarted(_ sender: UIButton) {
        UserDefaults().set(true, forKey: "getStarted")
        segue()
    }
    
    fileprivate func segue() {
        self.performSegue(withIdentifier: "getStarted", sender: self)
    }
}















