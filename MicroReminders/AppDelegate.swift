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
        
        beaconManager.stopMonitoringForAllRegions()
        Beacons.shared.listenToBeaconRegions(beaconManager: beaconManager)
        
        return true
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
        let respond = UNNotificationCategory(identifier: "respond_to_task", actions: [accept, decline], intentIdentifiers: [], options: [.customDismissAction])
        
        // register our actions
        UNUserNotificationCenter.current().setNotificationCategories([respond])
    }
    
    /* Handle accepting a notification */
    func handleAccept(_ notification: UNNotification) {
        TaskNotificationResponder().accept(notification)
    }
    
    /* Handle declining a notification */
    func handleDecline(_ notification: UNNotification, reason: String) {
        TaskNotificationResponder().decline(notification, reason: reason)
    }
    
    /** Handle an h_action notification being cleared */
    func handleClear(_ notification: UNNotification) {
        TaskNotificationResponder().clearSnooze(notification)
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
            TaskNotificationResponder().accept(notification)
        })
        let decline = UIAlertAction(title: "Not now...", style: .cancel, handler: { action in
            let alert = UIAlertController(title: nil, message: "Why not? (Optional)", preferredStyle: .alert)
            let enter = UIAlertAction(title: "Enter", style: .default, handler: { action in
                let reason = alert.textFields?[0].text
                TaskNotificationResponder().decline(notification, reason: reason)
            })
            let cancel = UIAlertAction(title: "Decline", style: .cancel, handler: { action in
                TaskNotificationResponder().decline(notification, reason: nil)
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
        
        Logger().logRegionInteraction(region: regionInt, way: .entered)
        TaskNotificationSender().entered(region: regionInt)
    }
    
    /** Keep track of when we exited a region */
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        print("exited \(region.identifier), \(Date())")
        
        let regionInt: UInt16 = region.minor!.uint16Value
        
        Logger().logRegionInteraction(region: regionInt, way: .exited)
        TaskNotificationSender().exited(region: regionInt)
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
}

