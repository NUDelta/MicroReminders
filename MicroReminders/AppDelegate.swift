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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Handle notification in app after launching from notification (?)
        if (launchOptions != nil) {
            if let notification = launchOptions![UIApplicationLaunchOptionsKey.localNotification] as! UILocalNotification? {
                handleNotificationInApp(notification)
            }
        }
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization() // Get location permissions
        
        /* register our beacons */
        for minor in beacons.keys {
            self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: beacons[minor]!))
        }
        
        /* Set up notification actions */
        setUpNotificationActions()
        
        return true
    }

    // Handle notification in app (received while in app)
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        handleNotificationInApp(notification)
    }
    
    
    // **********************************
    // Utility functions
    // **********************************
    
    /* Set up notification actions */
    func setUpNotificationActions() {
        
        let notificationActionMarkDone = createNotificationAction("MARK_DONE", title: "Mark done", destructive: true, authenticationRequired: false, activationMode: UIUserNotificationActivationMode.background)
        let notificationActionForLater = createNotificationAction("FOR_LATER", title: "Snooze", destructive: true, authenticationRequired: false, activationMode: UIUserNotificationActivationMode.background)
        
        // put our actions in a category
        let notificationCategoryRespondToMT = UIMutableUserNotificationCategory()
        notificationCategoryRespondToMT.identifier = "RESPOND_TO_MT_DEFAULT"
        let actions = [notificationActionMarkDone, notificationActionForLater]
        notificationCategoryRespondToMT.setActions(actions, for: UIUserNotificationActionContext.default)
        notificationCategoryRespondToMT.setActions([notificationActionMarkDone, notificationActionForLater], for: UIUserNotificationActionContext.minimal)
        
        // register our actions
        let types = UIUserNotificationType.alert
        let settings = UIUserNotificationSettings(types: types, categories: NSSet(object: notificationCategoryRespondToMT) as? Set<UIUserNotificationCategory>)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    /* Create and show alertController to handle notification in-app */
    func handleNotificationInApp(_ notification: UILocalNotification) {
        print("Handling notification in app!")
        let alert = handleMTAlertController(notification)
        self.window?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
    
    /* Create alertController to handle notification in-app */
    func handleMTAlertController(_ notification: UILocalNotification) -> UIAlertController {
        let alert = UIAlertController(title: "\(notification.userInfo!["task"]!)", message: "Would you like to snooze this microtask or mark it done?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Snooze", style: .cancel, handler: { [unowned self, notification] (action: UIAlertAction) in
            print("for later action")
            // Handle snoozing
            })
        let markDone = UIAlertAction(title: "Mark done", style: .default, handler: { [unowned self, notification] (action: UIAlertAction) in
            print("marked done action")
            // Handle marking done
            })
        alert.addAction(cancel); alert.addAction(markDone)
        return alert
    }
    
    /* Create notification actions */
    func createNotificationAction(_ identifier: String, title: String, destructive: Bool, authenticationRequired: Bool, activationMode: UIUserNotificationActivationMode) -> UIMutableUserNotificationAction {
        let notificationAction = UIMutableUserNotificationAction()
        notificationAction.identifier = identifier; notificationAction.title = title
        notificationAction.isDestructive = true; notificationAction.isAuthenticationRequired = false
        notificationAction.activationMode = UIUserNotificationActivationMode.background
        return notificationAction
    }
    
    /* Handle notification actions */
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: (@escaping () -> Void)) {
        
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
    
    func handleMarkDone(_ notification: UILocalNotification){
        print("marked done action")
    }
    
    func handleForLater(_ notification: UILocalNotification){
        print("for later action")
    }
    
    /* Send notifications when we enter a region */
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        print("entered \(region.identifier)")
        notify.notify(beacons[UInt16((region.minor?.intValue)!)]!)
    }
    
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        print("exited \(region.identifier)")
    }
}

