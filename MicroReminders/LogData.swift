//
//  LogData.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 5/19/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class LogData {

    let owner:String

    let regionChangeRef = Firebase(url: "https://microreminders.firebaseio.com/RegionChange")
    let notificationRef = Firebase(url: "https://microreminders.firebaseio.com/NotificationInteraction")

    init(owner: String){
        self.owner = owner
    }

    func logEntered(region:String){
        let log = ["region":region, "owner":owner, "state":"entered"]
        regionChangeRef.childByAppendingPath(self.owner).childByAppendingPath(date_to_string()).setValue(log as AnyObject)
    }

    func logExited(region:String){
        let log = ["region":region, "owner":owner, "state":"exited"]
        regionChangeRef.childByAppendingPath(self.owner).childByAppendingPath(date_to_string()).setValue(log as AnyObject)
    }
    
    func logDismissed(notification: UILocalNotification){
        let userInfo = notification.userInfo!
        let microtask = userInfo["microtask"] as! String
        let task = userInfo["owner"] as! String
        let step = userInfo["currentStep"] as! String
        let log = ["type":"dismissed", "microtask":microtask, "task":task, "step":step]
        notificationRef.childByAppendingPath(self.owner).childByAppendingPath(date_to_string()).setValue(log as AnyObject)
    }
    
    func logCompleted(notification:UILocalNotification){
        let userInfo = notification.userInfo!
        let microtask = userInfo["microtask"] as! String
        let task = userInfo["owner"] as! String
        let step = userInfo["currentStep"] as! String
        let log = ["type":"completed", "microtask":microtask, "task":task, "step":step]
        notificationRef.childByAppendingPath(self.owner).childByAppendingPath(date_to_string()).setValue(log as AnyObject)
    }

}
