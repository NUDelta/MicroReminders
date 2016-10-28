//
//  TaskLandingPageTableTableViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/14/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

class TaskLandingPageTableViewController: UITableViewController {
    
    var prepopTaskRef: FIRDatabaseReference!
    var myTaskRef: FIRDatabaseReference!
    
    var prepopTaskList = [Task]()
    var myTaskList = [Task]()
    var displayTaskList = [Task]()
    
    var tappedCell = -1

    // Table loading
    override func viewDidLoad() {
        super.viewDidLoad()
        prepopTaskRef = FIRDatabase.database().reference().child("Tasks/Prepopulated")
        myTaskRef = FIRDatabase.database().reference().child("Tasks/\(UIDevice.currentDevice().identifierForVendor!.UUIDString)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayTasks()
    }
    
    func updateDisplayTasks() -> Void {
        prepopTaskList = [Task]()
        myTaskList = [Task]()
        displayTaskList = [Task]()
        prepopTaskRef.observeSingleEventOfType(.Value, withBlock: { prepopSnapshot in
            self.fillTaskList(prepopSnapshot, taskList: &self.prepopTaskList)
            
            self.myTaskRef.observeSingleEventOfType(.Value, withBlock: { myTaskSnapshot in
                self.fillTaskList(myTaskSnapshot, taskList: &self.myTaskList)
                
                let myTaskIds = self.myTaskList.map({ task in task._id })
                self.displayTaskList = self.prepopTaskList.filter({ task in !myTaskIds.contains(task._id) })
                
                self.displayTaskList.sortInPlace({ (task1, task2) in task1.name < task2.name })
                self.tableView.reloadData()
            })
        })
    }
    
    func fillTaskList(snapshot: FIRDataSnapshot, inout taskList: [Task]) -> Void {
        let taskJSON = snapshot.value as? NSDictionary
        
        if taskJSON != nil {
            for (_id, taskData) in taskJSON! {
                var taskDict = taskData as! Dictionary<String, String>
                let task = Task(_id as! String, taskDict["task"]!, taskDict["category1"]!, taskDict["category2"]!,
                                taskDict["category3"]!, taskDict["mov_sta"]!, taskDict["location"]!)
                
                taskList.append(task)
            }
        }
    }

    // Table display
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTaskList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskLandingPageCell", forIndexPath: indexPath) as! TaskLandingPageCell

        let task = displayTaskList[indexPath.row]
        cell.taskName.text = task.name
        cell.taskTime.text = task.length

        return cell
    }
    
    // Table interaction
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let taskInd = indexPath.row
        if (tappedCell == indexPath.row) {
            (UIApplication.sharedApplication().delegate as! AppDelegate).pickLocationForTask(self, taskWithoutLoc: self.displayTaskList[taskInd])
        }
        
        tappedCell = taskInd
    }
    
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




















