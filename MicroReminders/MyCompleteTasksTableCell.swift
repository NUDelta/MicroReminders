//
//  MyCompleteTasksTableCell.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class MyCompleteTasksTableCell: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    var tableViewController: UITableViewController! = nil
 
    var task: Task! = nil
}
