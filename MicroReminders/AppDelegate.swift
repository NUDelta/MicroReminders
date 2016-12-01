//
//  AppDelegate.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/5/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    let beacons = Beacons.sharedInstance.beacons
    var beaconExitTimes = Beacons.sharedInstance.beaconExitTimes
    let beaconManager = ESTBeaconManager()
    
    override init() {
        FIRApp.configure() // Configure Firebase (must happen before any Firebase-using classes init)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            print("Notification authorization granted!")
        })
        UNUserNotificationCenter.current().delegate = self

        /* Set up notification actions */
        setUpNotificationActions()
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization() // Get location permissions
        
        /* register our beacons */
        for minor in beacons.keys {
            self.beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: beacons[minor]!))
        }
        
        return true
    }

    /* Handle notification in app (received while in app) */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
    
    /* Handle notification actions */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "done":
            handleDone(response.notification)
        case "snooze":
            handleSnooze(response.notification)
        case UNNotificationDismissActionIdentifier:
            handleClear(response.notification)
        case UNNotificationDefaultActionIdentifier:
            handleInApp(response.notification)
        default:
            break
        }
        completionHandler()
    }
    
    
    // **********************************
    // Utility functions
    // **********************************
    
    /* Set up notification actions */
    func setUpNotificationActions() {
        
        let done = UNNotificationAction(identifier: "done", title: "Done with task!", options: [])
        let snooze = UNNotificationAction(identifier: "snooze", title: "Snooze", options: [])
        
        // put our actions in a category
        let respond = UNNotificationCategory(identifier: "respond_to_task", actions: [done, snooze], intentIdentifiers: [], options: [.customDismissAction])
        
        // register our actions
        UNUserNotificationCenter.current().setNotificationCategories([respond])
    }
    
    /* Handle marking a task done */
    func handleDone(_ notification: UNNotification) {
        TaskNotificationResponder().markDone(notification)
    }
    
    /* Handle snoozing a task */
    func handleSnooze(_ notification: UNNotification) {
        TaskNotificationResponder().snooze(notification)
    }
    
    /** Handle a task notification being cleared */
    func handleClear(_ notification: UNNotification) {
        TaskNotificationResponder().clearSnooze(notification)
    }
    
    /* Create alertController to handle notification in-app */
    func handleInApp(_ notification: UNNotification) {
        let title = "\(notification.request.content.userInfo["t_name"]!)"
        let alert = UIAlertController(title: title, message: "Would you like to snooze this microtask or is it done?", preferredStyle: .alert)
        let snooze = UIAlertAction(title: "Snooze", style: .default, handler: { (action: UIAlertAction) in
            self.handleSnooze(notification)
        })
        let markDone = UIAlertAction(title: "Done with task", style: .default, handler: { (action: UIAlertAction) in
            self.handleDone(notification)
        })
        alert.addAction(snooze); alert.addAction(markDone)
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    /* Send notifications when we enter a region */
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        print("entered \(region.identifier)")
        let regionInt: UInt16 = region.minor!.uint16Value
        
        let threshold: Double = 15 // Minimum number of minutes outside region before notification
        let then = beaconExitTimes[regionInt]!
        
        /* 
         This should never be relevant - we should only ever enter after exiting. What that means
         is that we should check this value before it is set here, and set it again in "didExitRegion"
         before we check it next. However, since the beacons are buggy, and I'm concerned about
         sequential "didEnterRegion" events, I'm leaving this in here.
         */
        beaconExitTimes[regionInt] = Date(timeIntervalSinceNow: Double(Int.max))
        
        if (Date().timeIntervalSince(then) > 60.0*threshold) {
            TaskNotificationSender().notify(beacons[regionInt]!)
        }
    }
    
    /** Keep track of when we exited a region */
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        print("exited \(region.identifier)")
        let regionInt: UInt16 = region.minor!.uint16Value
        
        /*
         This is to ensure that we only reset the exit time if the previous region event was an
         entrance, protecting against sequential exit events.
         */
        if (beaconExitTimes[regionInt]!.timeIntervalSinceNow > Double(Int.max/2)) {
            beaconExitTimes[regionInt] = Date()
        }
    }
}

