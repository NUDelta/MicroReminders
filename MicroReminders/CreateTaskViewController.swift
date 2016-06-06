//
//  ViewController.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/5/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class CreateTaskViewController: UIViewController, UITextFieldDelegate {

    var task = MakeTask(owner: UIDevice.currentDevice().identifierForVendor!.UUIDString)
    
    // Make keyboard disappear on return key
    @IBOutlet weak var mainTask: UITextField! = nil
    @IBOutlet weak var microtask1: UITextField! = nil
    @IBOutlet weak var microtask2: UITextField! = nil
    @IBOutlet weak var microtask3: UITextField! = nil
    
    override func viewDidLoad() {
        mainTask.delegate = self
        microtask1.delegate = self
        microtask2.delegate = self
        microtask3.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Task entering actions
    @IBAction func MainTaskEntered(sender: UITextField) { task.setMainTask(sender.text!) }
    
    @IBAction func microTaskEntered(sender: UITextField) { task.setMicroTask(sender.text!, index: sender.tag) }
    
    @IBAction func locationEntered(sender: UITextField) { task.setLocation(sender.text!, index: sender.tag) }
    
    @IBAction func saveTask(sender: UIButton) {
        task.post()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func pickLocation(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Please pick a room!", message: "Select a room", preferredStyle: .ActionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action -> Void in print("cancel")
        })
        actionSheet.addAction(cancelActionButton)
        
        let beacons = (UIApplication.sharedApplication().delegate as! AppDelegate).beacons
//        beacons[0] = "other"
        
        var actionButton = UIAlertAction()
        for name in beacons.values {
            actionButton = UIAlertAction(title: name.capitalizedString, style: .Default, handler: { action -> Void in
                sender.setTitle(name.capitalizedString, forState: .Normal)
                self.task.setLocation(name, index: sender.tag)
            })
            actionSheet.addAction(actionButton)
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
}



















