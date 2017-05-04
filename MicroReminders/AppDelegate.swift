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
    let notificationBrain = NotificationBrain()
    let notificationHandler = NotificationHandler()
    
    /* ------ */
    /* Keep app alive in background */
    
    var jobExpired: Bool = false
    var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func startBackgroundTask() {
        DispatchQueue.global().async {
            while(!self.jobExpired) {
                // Do a check
                print("sensing")
                FIRDatabase.database().reference().child("log").child("\(Int(Date().timeIntervalSince1970))").setValue("sensing_\(self.bgTask)")
                Thread.sleep(forTimeInterval: 1)
            }
            
            self.jobExpired = false
        }
    }
    
    /* ------ */
    
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
        
        beaconManager.stopMonitoringForAllRegions()
        Beacons.shared.listenToBeaconRegions(beaconManager: beaconManager)
    
        return true
    }

    /* ------ */
    /* Keep app alive */
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        func expirationHandler() {
            print("killing")
            FIRDatabase.database().reference().child("log").child("\(Int(Date().timeIntervalSince1970))").setValue("killing_\(self.bgTask)")
            
            UIApplication.shared.endBackgroundTask(self.bgTask)
            
            self.bgTask = UIBackgroundTaskInvalid
            
            self.bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: expirationHandler)
            
            self.jobExpired = true
            while (self.jobExpired) {
                print("spinning")
                FIRDatabase.database().reference().child("log").child("\(Int(Date().timeIntervalSince1970))").setValue("spinning_\(self.bgTask)")
                Thread.sleep(forTimeInterval: 1)
            }
        }
        
        application.beginBackgroundTask(expirationHandler: expirationHandler)
        self.startBackgroundTask()
    }

    /* Handle notification in app (received while in app) */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound, .badge])
    }
    
    /* Handle notification actions */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "accept":
            handleAccept(response.notification)
            break
        case "decline":
            let textResponse = response as! UNTextInputNotificationResponse
            handleDecline(response.notification, reason: textResponse.userText)
            break
        case UNNotificationDismissActionIdentifier:
            handleClear(response.notification)
            break
        case UNNotificationDefaultActionIdentifier:
            handleAppOpened(response.notification)
            break
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
        
        let accept = UNNotificationAction(identifier: "accept", title: "I'll do that now!", options: [])
        let decline = UNTextInputNotificationAction(identifier: "decline", title: "Not now...", options: [], textInputButtonTitle: "Enter", textInputPlaceholder: "Why not? (Optional)")
        
        // put our actions in a category
        let respond = UNNotificationCategory(identifier: "action_notification", actions: [accept, decline], intentIdentifiers: [], options: [.customDismissAction])
        
        // register our actions
        UNUserNotificationCenter.current().setNotificationCategories([respond])
    }
    
    /* Handle accepting a notification */
    func handleAccept(_ notification: UNNotification) {
        notificationHandler.accept(notification)
    }
    
    /* Handle declining a notification */
    func handleDecline(_ notification: UNNotification, reason: String) {
        notificationHandler.decline(notification, reason: reason)
    }
    
    /** Handle an h_action notification being cleared */
    func handleClear(_ notification: UNNotification) {
        notificationHandler.clear(notification)
    }
    
    /**
     Handle the notification being tapped and opening the app.
     
     Present an action sheet with the same options as the notification.
     If declined, present an alert with a text field to ask "why not".
     */
    func handleAppOpened(_ notification: UNNotification) {
        let rVC = self.window?.rootViewController!
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let accept = UIAlertAction(title: "I'll do that now!", style: .default, handler: { action in
            self.notificationHandler.accept(notification)
        })
        let decline = UIAlertAction(title: "Not now...", style: .cancel, handler: { action in
            let alert = UIAlertController(title: nil, message: "Why not? (Optional)", preferredStyle: .alert)
            let enter = UIAlertAction(title: "Enter", style: .default, handler: { action in
                let reason = alert.textFields?[0].text
                self.notificationHandler.decline(notification, reason: reason)
            })
            let cancel = UIAlertAction(title: "Decline", style: .cancel, handler: { action in
                self.notificationHandler.decline(notification, reason: nil)
            })
            
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = "What makes now a bad time?"
            })
            
            alert.addAction(enter)
            alert.addAction(cancel)
            rVC!.present(alert, animated: true, completion: nil)
        })
        alert.addAction(accept)
        alert.addAction(decline)
        rVC!.present(alert, animated: true, completion: nil)
    }
    
    /* Send notifications when we enter a region */
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        print("entered \(region.identifier) , \(Date())")
        
        let regionInt: UInt16 = region.minor!.uint16Value
        
        notificationBrain.entered(region: regionInt)
    }
    
    /** Keep track of when we exited a region */
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        print("exited \(region.identifier), \(Date())")
        
        let regionInt: UInt16 = region.minor!.uint16Value
        
        notificationBrain.exited(region: regionInt)
    }
    
    /** Monitoring failing */
    func beaconManager(_ manager: Any, monitoringDidFailFor region: CLBeaconRegion?, withError error: Error) {
        print("Monitoring failed for: \(String(describing: region?.identifier)) with error \(error.localizedDescription) at \(Date())")
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
    
    /* --------------------------------------- */
    /* Keep the app alive in the background indefinitely */
    
    
}





















