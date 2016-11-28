//
//  TaskLandingPageTableCell.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/12/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class AddTaskTableCell: UITableViewCell {

    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var subcategory: UILabel!
    
    var task: Task! = nil
    var tableViewController: AddTaskTableViewController! = nil
    
    //*************** Autogenerated
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.taskName.font = UIFont.boldSystemFont(ofSize: self.taskName.font.pointSize)
        }
        else {
            self.taskName.font = UIFont.systemFont(ofSize: self.taskName.font.pointSize)
        }
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        task.pickLocationAndPushTask(tableViewController, handler: { self.tableViewController.updateDisplayTasks() })
    }
}