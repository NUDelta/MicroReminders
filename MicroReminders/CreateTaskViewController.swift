//
//  ViewController.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/5/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var task = MakeTask()
    let notify = NotifyMicrotasks()
    
    @IBAction func MainTaskEntered(sender: UITextField) {
        task.setMainTask(sender.text!)
    }
    
    @IBAction func microTaskEntered(sender: UITextField) {
        task.setMicroTask(sender.text!, index: sender.tag)
    }
    
    @IBAction func locationEntered(sender: UITextField) {
        task.setLocation(sender.text!, index: sender.tag)
    }
    
    @IBAction func showTask(sender: UIButton) {
        notify.getCurrentNotifications()
    }
    
    @IBAction func saveTask(sender: UIButton) {
        task.post()
    }
}

