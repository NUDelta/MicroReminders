//
//  AppDelegate.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/5/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {
    
    var window: UIWindow?
    let beaconManager = ESTBeaconManager()
    
    // ADEL
//    var beacons: [UInt16: String] = [53805: "bike", 41424: "bedroom", 35710: "helens apartment"]
    // hotel (bedroom): 41424
    // bravo (bike): 53805
    // delta (helens apartment): 35710
    
    // HELEN
//    var beacons: [UInt16: String] = [34944: "car", 62318: "living room", 44363: "bedroom"]
    // tango (car): 34944
    // uniform (living room): 62318
    // victor (bedroom): 44363
    
    // BILL
//    var beacons: [UInt16: String] = [32706: "bedroom", 58574: "suite lounge"]
    // papa (bedroom): 32706
    // alpha (suite lounge): 58574
    // india (AG52): 30885
    
    // ME/Max
    var beacons: [UInt16: String] = [59582: "kitchen", 39192: "fireplace", 49825: "bathroom"]
    // var beacons: [UInt16: String] = [59582: "romeo"]
    // var beacons: [UInt16: String] = [39192: "whiskey"]
    // var beacons: [UInt16: String] = [49825: "quebec"]
    
    // No beacons
//    var beacons: [UInt16: String] = [:]
    
    var notify: Notify
    var log: LogData
    
    
    override init() {
        
        /* Configure Firebase and Firebase-using clients */
        FIRApp.configure()
        notify = Notify()
        log = LogData(owner: UIDevice.currentDevice().identifierForVendor!.UUIDString)
        
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Handle notification in app after launching from notification (?)
        if (launchOptions != nil) {
            if let notification = launchOptions![UIApplicationLaunchOptionsLocalNotificationKey] as! UILocalNotification? {
                handleNotificationInApp(notification)
            }
        }
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization() // Get location permissions
        
        /* register our beacons */
        for minor in beacons.keys {
            self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: beacons[minor]!))
        }
        
        /* Set up notification actions */
        setUpNotificationActions()
        
        return true
    }

    // Handle notification in app (received while in app)
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        handleNotificationInApp(notification)
    }
    
    
    // **********************************
    // Utility functions
    // **********************************
    
    /* Set up notification actions */
    func setUpNotificationActions() {
        
        let notificationActionMarkDone = createNotificationAction("MARK_DONE", title: "Done!", destructive: true, authenticationRequired: false, activationMode: UIUserNotificationActivationMode.Background)
        let notificationActionForLater = createNotificationAction("FOR_LATER", title: "Later", destructive: true, authenticationRequired: false, activationMode: UIUserNotificationActivationMode.Background)
        
        // put our actions in a category
        let notificationCategoryRespondToMT = UIMutableUserNotificationCategory()
        notificationCategoryRespondToMT.identifier = "RESPOND_TO_MT_DEFAULT"
        let actions = [notificationActionMarkDone, notificationActionForLater]
        notificationCategoryRespondToMT.setActions(actions, forContext: UIUserNotificationActionContext.Default)
        notificationCategoryRespondToMT.setActions([notificationActionMarkDone, notificationActionForLater], forContext: UIUserNotificationActionContext.Minimal)
        
        // register our actions
        let types = UIUserNotificationType.Alert
        let settings = UIUserNotificationSettings(forTypes: types, categories: NSSet(object: notificationCategoryRespondToMT) as? Set<UIUserNotificationCategory>)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    /* Create and show alertController to handle notification in-app */
    func handleNotificationInApp(notification: UILocalNotification) {
        print("Handling notification in app!")
        let alert = handleMTAlertController(notification)
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: {
        })
    }
    
    /* Create alertController to handle notification in-app */
    func handleMTAlertController(notification: UILocalNotification) -> UIAlertController {
        let alert = UIAlertController(title: "\(notification.userInfo!["task"]!)", message: "Would you like to snooze this microtask or mark it done?", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Snooze", style: .Cancel, handler: { [unowned self, notification] (action: UIAlertAction) in
            print("for later action")
            // Handle snoozing
            })
        let markDone = UIAlertAction(title: "Mark done", style: .Default, handler: { [unowned self, notification] (action: UIAlertAction) in
            print("marked done action")
            // Handle marking done
            })
        alert.addAction(cancel); alert.addAction(markDone)
        return alert
    }
    
    /* Create notification actions */
    func createNotificationAction(identifier: String, title: String, destructive: Bool, authenticationRequired: Bool, activationMode: UIUserNotificationActivationMode) -> UIMutableUserNotificationAction {
        let notificationAction = UIMutableUserNotificationAction()
        notificationAction.identifier = identifier; notificationAction.title = title
        notificationAction.destructive = true; notificationAction.authenticationRequired = false
        notificationAction.activationMode = UIUserNotificationActivationMode.Background
        return notificationAction
    }
    
    /* Handle notification actions */
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: (() -> Void)) {
        
        // switch on the action identifier
        switch identifier!{
        case "MARK_DONE":
            handleMarkDone(notification)
        case "FOR_LATER":
            handleForLater(notification)
        default:
            break
        }
        completionHandler()
    }
    
    func handleMarkDone(notification: UILocalNotification){
        print("marked done action")
    }
    
    func handleForLater(notification: UILocalNotification){
        print("for later action")
    }
    
    /* Send notifications when we enter a region */
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        print("entered \(region.identifier)")
        notify.notify(beacons[UInt16((region.minor?.integerValue)!)]!)
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        print("exited \(region.identifier)")
    }
    
    func pickLocationForTask(parentViewController: UIViewController, taskWithoutLoc: Task) {
        let actionSheet = UIAlertController(title: "Please pick a room!", message: "Select a room", preferredStyle: .ActionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil )
        actionSheet.addAction(cancelActionButton)
        
        var actionButton: UIAlertAction
        for name in beacons.values {
            actionButton = UIAlertAction(title: name.capitalizedString, style: .Default, handler: { action -> Void in
                
                Task(taskWithoutLoc._id, taskWithoutLoc.name, taskWithoutLoc.category1, taskWithoutLoc.category2, taskWithoutLoc.category3, taskWithoutLoc.mov_sta, action.title!).pushToFirebase()
                
                let alert = UIAlertController(title: "Task added!", message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
                parentViewController.presentViewController(alert, animated: true, completion: nil)
            })
            actionSheet.addAction(actionButton)
        }
        
        parentViewController.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
}

