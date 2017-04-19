//
//  MyTasksTableCell.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var timeRange: UILabel!
    
    var tableViewController: TaskList! = nil
 
    var task: Task! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func constrainExistingTask() {
        self.tableViewController.existingTaskToConstrain = task
        self.tableViewController.performSegue(withIdentifier: "constrainExistingTask", sender: self)
    }
}
