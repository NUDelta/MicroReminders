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
    
    var notify: Notify
    var beacons = Beacons.sharedInstance.beacons
    
    override init() {
        
        /* Configure Firebase and Firebase-using clients */
        FIRApp.configure()
        notify = Notify()
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
        
        let notificationActionMarkDone = createNotificationAction("MARK_DONE", title: "Mark done", destructive: true, authenticationRequired: false, activationMode: UIUserNotificationActivationMode.Background)
        let notificationActionForLater = createNotificationAction("FOR_LATER", title: "Snooze", destructive: true, authenticationRequired: false, activationMode: UIUserNotificationActivationMode.Background)
        
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
}

