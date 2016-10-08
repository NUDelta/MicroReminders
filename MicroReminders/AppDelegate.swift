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
//    var beacons: [UInt16: String] = [59582: "kitchen", 39192: "fireplace", 49825: "bathroom"]
    // var beacons: [UInt16: String] = [59582: "romeo"]
    // var beacons: [UInt16: String] = [39192: "whiskey"]
    // var beacons: [UInt16: String] = [49825: "quebec"]
    
    // No beacons
    var beacons: [UInt16: String] = [:]
    
    var notify: NotifyMicrotasks
    var log: LogData
    
    
    override init() {
        
        /* Configure Firebase and Firebase-using clients */
        FIRApp.configure()
        notify = NotifyMicrotasks()
        log = LogData(owner: UIDevice.currentDevice().identifierForVendor!.UUIDString)
        
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
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
        
        /* set contexts to monitor */
        notify.setContext(Array(beacons.values))
        
        return true
    }

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
        let alert = handleMTAlertController(notification)
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: {
        })
    }
    
    /* Create alertController to handle notification in-app */
    func handleMTAlertController(notification: UILocalNotification) -> UIAlertController {
        let alert = UIAlertController(title: "\(notification.userInfo!["description"]!)", message: "Would you like to snooze this microtask or mark it done?", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Snooze", style: .Cancel, handler: { [unowned self, notification] (action: UIAlertAction) in
                self.notify.removeActiveNotification(notification)
                self.log.logDismissed(notification)
            })
        let markDone = UIAlertAction(title: "Mark done", style: .Default, handler: { [unowned self, notification] (action: UIAlertAction) in
                self.notify.markMTdone(notification)
                self.log.logCompleted(notification)
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
        notify.removeActiveNotification(notification)
        notify.markMTdone(notification)
        log.logCompleted(notification)
    }
    
    func handleForLater(notification: UILocalNotification){
        print("for later action")
        notify.removeActiveNotification(notification)
        log.logDismissed(notification)
    }
    
    /* Send notifications when we enter a region */
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        notify.notify()
        log.logEntered(region.identifier)
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        log.logExited(region.identifier)
    }
    
}

