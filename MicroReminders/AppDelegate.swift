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

// http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

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
        
        Beacons.listenToBeaconRegions(beaconManager: beaconManager)
        
        return true
    }

    /* Handle notification in app (received while in app) */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
    
    /* Handle notification actions */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "snooze":
            handleSnooze(response.notification)
        case UNNotificationDismissActionIdentifier:
            handleClear(response.notification)
//        case UNNotificationDefaultActionIdentifier:
//            handleInApp(response.notification)
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
        
        let snooze = UNNotificationAction(identifier: "snooze", title: "Snooze", options: [])
        
        // put our actions in a category
        let respond = UNNotificationCategory(identifier: "respond_to_task", actions: [snooze], intentIdentifiers: [], options: [.customDismissAction])
        
        // register our actions
        UNUserNotificationCenter.current().setNotificationCategories([respond])
    }
    
    /* Handle snoozing a task */
    func handleSnooze(_ notification: UNNotification) {
        TaskNotificationResponder().snooze(notification)
    }
    
    /** Handle a task notification being cleared */
    func handleClear(_ notification: UNNotification) {
        TaskNotificationResponder().clearSnooze(notification)
    }
    
    func handleAppOpened(_ notification: UNNotification) {
        TaskNotificationResponder().appOpenedSnooze(notification)
    }
    
    /* Send notifications when we enter a region */
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        print("entered \(region.identifier) , \(Date())")
        let regionInt: UInt16 = region.minor!.uint16Value
        
        let location = Beacons.getBeaconLocation(forKey: regionInt)
        let then = Beacons.getExitTime(forKey: regionInt)
        
        let threshold: Double = renotifyThreshold[userKey]! // Minimum number of minutes outside region before notification
        
        /* 
         This should never be relevant - we should only ever enter after exiting. What that means
         is that we should check this value before it is set here, and set it again in "didExitRegion"
         before we check it next. However, since the beacons are buggy, and I'm concerned about
         sequential "didEnterRegion" events, I'm leaving this in here.
         */
        Beacons.setExitTime(forKey: regionInt, to: Date(timeIntervalSinceNow: Double(Int.max)))
        
        if (Date().timeIntervalSince(then) > 60.0*threshold) {
            TaskNotificationSender().notify(location)
        }
    }
    
    /** Keep track of when we exited a region */
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        print("exited \(region.identifier), \(Date())")
        let regionInt: UInt16 = region.minor!.uint16Value
        
        let then = Beacons.getExitTime(forKey: regionInt)
        
        /*
         This is to ensure that we only reset the exit time if the previous region event was an
         entrance, protecting against sequential exit events.
         */
        if (then.timeIntervalSinceNow > Double(Int.max/2)) {
            Beacons.setExitTime(forKey: regionInt, to: Date())
        }
    }
    
    /** Monitoring failing */
    func beaconManager(_ manager: Any, monitoringDidFailFor region: CLBeaconRegion?, withError error: Error) {
        print("Monitoring failed for: \(region?.identifier) with error \(error.localizedDescription) at \(Date())")
    }
    
    /** Beacon manager failing */
    func beaconManager(_ manager: Any, didFailWithError error: Error) {
        print("Beacon manager failed with error: \(error.localizedDescription), \(Date())")
    }
    
    /** Region state determined */
    func beaconManager(_ manager: Any, didDetermineState state: CLRegionState, for region: CLBeaconRegion) {
        let stateString: String = {
            switch state.rawValue {
            case 0:
                return "unknown"
            case 1:
                return "inside"
            case 2:
                return "outside"
            default:
                return "AHHHHH"
            }
        }()
        
        print("determined state for region: \(region.identifier) to be *\(stateString)*, \(Date())")
    }
}

