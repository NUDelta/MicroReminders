//
//  BackgroundTasker.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/30/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

/** Handles running context checking in the background */
class BackgroundSenser {
//    fileprivate let bgTask: BackgroundTaskManager = BackgroundTaskManager.shared()
//    
//    fileprivate var bgTimer: Timer? = Timer()
//    fileprivate var bgDelayTimer: Timer? = Timer()
//    
//    /** Steps
//     
//     1) For each action with a location time delay, start a timer
//     
//     2) For each action waiting for a plug event, add an observer
//     
//     3) For each action with a delay after a plug event, add an observer that starts a timer
//     
//     */
//    
//    func wait(for: [HabitAction], handler: (HabitAction) -> Void) {
//        
//    }
//
////    func delayAfterLocationEvent(...) {
////        
////    }
////    
////    func delayUntilPlugEvent(...) {
////        
////    }
////    
////    func delayAfterPlugEvent(...) {
////        
////    }
//    
//    //MARK: Background Task Functions
//    private func stopUpdates() {
//        print("Background stopping updates")
//        
//        if (bgTimer != nil) {
//            bgTimer!.invalidate()
//            bgTimer = nil
//        }
//    }
//    
//    func stopWithDelay() {
//        print("Background delay 50 seconds")
//    }
//    
//    func restartUpdates() {
//        print("Background restarting updates")
//        
//        if (bgTimer != nil) {
//            bgTimer!.invalidate()
//            bgTimer = nil
//        }
//        
//        startBGTask()
//    }
//    
//    override func viewDidLoad() {
//        // Do any additional setup after loading the view, typically from a nib.
//        super.viewDidLoad()
//        
//        startBGTask()
//    }
//    
//    func startBGTask() {
//        // all the stuff for background tasking.
//        if (bgTimer != nil) {
//            return
//        }
//        
//        let bgTask = BackgroundTaskManager.shared()
//        bgTask?.beginNewBackgroundTask()
//        
//        // restart location manager after 1 minute
//        let intervalLength = 60.0
//        let delayLength = intervalLength - 10.0
//        
//        bgTimer = Timer.scheduledTimer(timeInterval: intervalLength, target: self, selector: #selector(ViewController.restartUpdates), userInfo: nil, repeats: false)
//        
//        // keep location manager inactive for 10 seconds every minute to save battery
//        if (bgDelayTimer != nil) {
//            bgDelayTimer!.invalidate()
//            bgDelayTimer = nil
//        }
//        
//        bgDelayTimer = Timer.scheduledTimer(timeInterval: delayLength, target: self, selector: #selector(ViewController.stopWithDelay), userInfo: nil, repeats: false)
//    }
//
}
