//
//  GoalCardCollectionViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/20/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

class GoalCardCollectionViewController: UICollectionViewController {
    fileprivate let reuseID = "GoalCard"
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    fileprivate var tasks = [Task]()
    fileprivate var goals = [Goal]()
    
    var selectedGoal: Goal!
    
    override func viewWillAppear(_ animated: Bool) {
        Tasks.sharedInstance.taskListeners
            .updateValue(initTasksAndGoals, forKey: "collectGoals")
        
        initTasksAndGoals()
    }
    
    func initTasksAndGoals() {
        self.tasks = Tasks.sharedInstance.tasks
        self.goals = Tasks.sharedInstance.goals
        self.collectionView!.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Tasks.sharedInstance.taskListeners.removeValue(forKey: "collectGoals")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gtl = segue.destination as? GoalTaskList, segue.identifier == "tasksForGoal" {
            gtl.goal = selectedGoal
        }
    }
}

// Conform to UICollectionViewDataSource
extension GoalCardCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return goals.count - 1 }
        return goals.isEmpty ? 0 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! GoalCard
        
        cell.backgroundColor = GoalBoxSettings.sharedInstance.color
        cell.layer.cornerRadius = GoalBoxSettings.sharedInstance.cornerRadius
        cell.frame.size.height = GoalBoxSettings.sharedInstance.height
        
        var goal: Goal
        if indexPath.section == 0 {
            goal = goals[indexPath.row]
        }
        else {
            goal = goals.last! // Other goal
        }
        
        cell.goalName.text = goal.0
        cell.numPendingTasks.text = "\(goal.1.filter({ $0.completed == "false" }).count) pending tasks"
        
        return cell
    }
}

// Conform to UICollectionViewDelegate
extension GoalCardCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGoal = goals[indexPath.row]
        
        self.performSegue(withIdentifier: "tasksForGoal", sender: self)
    }
}

// Conform to UICollectionViewDelegateFlowLayout
extension GoalCardCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - sectionInsets.left * 2
        return CGSize(width: width, height: 100)
    }
}

// Utility stuff
extension GoalCardCollectionViewController {
    private func otherGoal() -> Goal {
        return ("Other", [Task]())
    }
    
    fileprivate func goalsFromTasks(tasks: [Task]) -> [Goal] {
        let goals = tasks
            .map({ (task) -> (String, Task) in return (task.goal, task) })
            .reduce([String: [Task]]()) { acc, t in
                var tmp = acc
                if (acc[t.0] != nil) {
                    tmp[t.0]!.append(t.1)
                }
                else {
                    tmp[t.0] = [t.1]
                }
                return tmp
            }
            .map({ (goal, taskList) in (goal, taskList) })
        
        return goals + [otherGoal()]
    }
}
























