//
//  AppDelegate.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/5/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {
    
    var window: UIWindow?
    let notify = NotifyMicrotasks()
    let beaconManager = ESTBeaconManager()
    //    var beacons: [UInt16: String] = [59582: "romeo", 39192: "whiskey", 49825: "quebec"]
    var beacons: [UInt16: String] = [59582: "romeo"]
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization() // Get location permissions
        
        /* register our beacons */
        for minor in beacons.keys {
            self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: beacons[minor]!))
        }
        
        /* Set up notification actions */
        // mark as done
        let notificationActionMarkDone = UIMutableUserNotificationAction()
        notificationActionMarkDone.identifier = "MARK_DONE"
        notificationActionMarkDone.title = "Done!"
        notificationActionMarkDone.destructive = true
        notificationActionMarkDone.authenticationRequired = false
        notificationActionMarkDone.activationMode = UIUserNotificationActivationMode.Background
        
        // mark as for later
        let notificationActionForLater = UIMutableUserNotificationAction()
        notificationActionForLater.identifier = "FOR_LATER"
        notificationActionForLater.title = "Later"
        notificationActionForLater.destructive = true
        notificationActionForLater.authenticationRequired = false
        notificationActionForLater.activationMode = UIUserNotificationActivationMode.Background
        
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
        
        return true
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
        // right now, relax
        print("marked done action")
        notify.removeActiveNotification(notification)
        notify.markMTdone(notification)
    }
    
    func handleForLater(notification: UILocalNotification){
        // right now, relax
        print("for later action")
        notify.removeActiveNotification(notification)
    }
    
    /* Send notifications when we enter a region */
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        /*
        let notification = UILocalNotification()
        notification.alertBody = "You're close to \(region.identifier)!"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        */
        
        notify.setContext("Dining room")
        notify.notify()
    }
    
    
    
    // Autopopulated functions
    //*********************************************
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

