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
    fileprivate var goals = [(String, [Task])]()
    
    override func viewWillAppear(_ animated: Bool) {
        tasks = Tasks.sharedInstance.tasks
        goals = goalsFromTasks(tasks: tasks)
    }
    
    fileprivate func goalsFromTasks(tasks: [Task]) -> [(String, [Task])] {
        return tasks
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
            }.map({ (goal, taskList) in (goal, taskList) })
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
        
        return cell
    }
}

// Conform to UICollectionViewDelegate
extension GoalCardCollectionViewController {
    
}

// Conform to UICollectionViewDelegateFlowLayout
extension GoalCardCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(20)
    }
}


























