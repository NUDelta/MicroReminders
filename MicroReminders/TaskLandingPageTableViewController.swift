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
    
    let prepopTaskRef = FIRDatabase.database().reference().child("Prepopulated")
    var taskList = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fillTaskList()
    }

    func fillTaskList() -> Void {
        prepopTaskRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let taskJSON = snapshot.value as! NSDictionary
            
            for (_id, taskData) in taskJSON {
                var taskDict = taskData as! Dictionary<String, String>
                self.taskList.append(Task(_id as! String, taskDict["task"]!, taskDict["category1"]!, taskDict["category2"]!,
                    taskDict["category3"]!, taskDict["mov_sta"]!))
            }
            
            self.tableView.reloadData()
        })
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskLandingPageCell", forIndexPath: indexPath) as! TaskLandingPageCell

        let task = taskList[indexPath.row]
        cell.taskName.text = task.name
        cell.taskTime.text = "1 min"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(taskList[indexPath.row])
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

struct Task {
    let _id: String
    let name: String
    let category1: String
    let category2: String
    let category3: String
    let mov_sta: String
    
    init(_ _id: String, _ name: String, _ category1: String, _ category2: String, _ category3: String, _ mov_sta: String) {
        self._id = _id
        self.name = name
        self.category1 = category1
        self.category2 = category2
        self.category3 = category3
        self.mov_sta = mov_sta
    }
}




















