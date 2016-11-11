//
//  MyTasksTableCell.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/22/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class MyIncompleteTasksTableCell: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    var tableViewController: UITableViewController! = nil
    
    var task: Task! = nil
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.taskName.font = UIFont.boldSystemFont(ofSize: self.taskName.font.pointSize)
        }
        else {
            self.taskName.font = UIFont.systemFont(ofSize: self.taskName.font.pointSize)
        }
    }
    
    @IBAction func infoTapped(_ sender: UIButton) {
        task.viewTaskDetailAlert(tableViewController)
    }
}
