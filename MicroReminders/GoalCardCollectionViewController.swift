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
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    fileprivate var tasks = [Task]()
    fileprivate var goals = [Goal]()
    
    fileprivate var selectedGoal: Goal!
    
    override func viewWillAppear(_ animated: Bool) {
        Tasks.sharedInstance.taskListeners.append({
            self.tasks = Tasks.sharedInstance.tasks
            self.goals = self.goalsFromTasks(tasks: self.tasks)
            self.collectionView!.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoalTaskList, segue.identifier == "tasksForGoal" {
            vc.goal = selectedGoal
        }
    }
}

// Conform to UICollectionViewDataSource
extension GoalCardCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goals.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! GoalCard
        
        cell.backgroundColor = UIColor.cyan
        cell.goalName.text = goals[indexPath.row].0
        cell.layer.cornerRadius = 5
        
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
























