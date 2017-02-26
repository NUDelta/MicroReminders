//
//  NewGoalViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/21/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

class NewGoalViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var coloredBox: UIView!
    @IBOutlet weak var whatsTheGoal: UITextField!
    
    override func viewDidLoad() {
        // TextField config
        whatsTheGoal.delegate = self
        whatsTheGoal.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        // colored box config
        coloredBox.frame.size.height = GoalBoxSettings.sharedInstance.height
        coloredBox.layer.cornerRadius = GoalBoxSettings.sharedInstance.cornerRadius
        coloredBox.backgroundColor = GoalBoxSettings.sharedInstance.color
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    @IBAction func addTaskTapped(_ sender: UIButton) {
        if (whatsTheGoal.text != "") {
            performSegue(withIdentifier: "taskForNewGoal", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ctcvc = segue.destination as? CustomTaskConstraintViewController, segue.identifier == "taskForNewGoal" {
            let goal = (whatsTheGoal.text!, [Task]())
            ctcvc.goal = goal
            ctcvc.pushHandler = {
                let root = self.navigationController?.viewControllers[0] as! GoalCardCollectionViewController
                _ = self.navigationController?.popToRootViewController(animated: false)
                
                root.selectedGoal = Tasks.sharedInstance.goalForTitle(title: goal.0)
                root.performSegue(withIdentifier: "tasksForGoal", sender: root)
            }
        }
    }
}
