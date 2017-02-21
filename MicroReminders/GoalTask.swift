//
//  MyTasksTableCell.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class GoalTask: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    
    var tableViewController: GoalTaskList! = nil
 
    var task: Task! = nil
    var active: Bool! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if active != nil {
            if active! {
                deactivate()
            }
        }
    }
    
    func deactivate() {
        let alert = UIAlertController(title: "Mark task done?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { alert in
            TaskInteractionManager().markListDone(self.task, handler: { self.tableViewController.updateDisplayTasks() })
        }))
        self.tableViewController.present(alert, animated: true, completion: nil)
    }
}
