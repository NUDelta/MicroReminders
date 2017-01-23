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
    
    var selectedTask: Task!
    var taskPushHandler: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TaskConstraintViewController, segue.identifier == "constrainTask" {
            vc.task = selectedTask
            vc.pushHandler = taskPushHandler
        }
    }
    
}
