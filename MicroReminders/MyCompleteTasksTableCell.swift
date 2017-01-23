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
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var location: UILabel!
    
    var tableViewController: MyCompleteTasksTableViewController! = nil
 
    var task: Task! = nil
    var active: Bool! = nil
    
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
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if active != nil {
            if active! {
                deactivate()
            }
            else {
                reactivate()
            }
        }
    }
    
    func reactivate() {
        let newTask = Task(task: task)
        
        let actionSheet = UIAlertController(title: "Reactivate this task!", message: "Same or new constraints?", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
        actionSheet.addAction(cancelActionButton)
        
        let sameConstraintsButton = UIAlertAction(title: "Same constraints", style: .default, handler: { action in
            newTask.pushToFirebase(handler: { self.tableViewController.updateDisplayTasks() })
            let alert = UIAlertController(title: "Task added!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        })
        
        let newConstraintsButton = UIAlertAction(title: "New constraints", style: .default, handler: { action in
            let grandparent = self.tableViewController.parent as! MyCompleteTasksViewController
            
            grandparent.selectedTask = newTask
            grandparent.taskPushHandler = {
                let _ = grandparent.navigationController?.popViewController(animated: true)
                self.tableViewController.updateDisplayTasks()
            }
            
            grandparent.performSegue(withIdentifier: "constrainTask", sender: self)
        })

        actionSheet.addAction(sameConstraintsButton)
        actionSheet.addAction(newConstraintsButton)
        tableViewController.present(actionSheet, animated: true, completion: nil)
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
