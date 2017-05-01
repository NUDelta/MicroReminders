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
    fileprivate let backgroundTaskManager = BackgroundTaskManager()
    fileprivate let bgTask: BackgroundTaskManager = BackgroundTaskManager.shared()

    func delayAfterLocationEvent(...) {
        
    }
    
    func delayUntilPlugEvent(...) {
        
    }
    
    func delayAfterPlugEvent(...) {
        
    }
    
    
    // background task
    
    
    var bgTimer: Timer? = Timer()
    var bgDelayTimer: Timer? = Timer()
    
    //MARK: Background Task Functions
    private func stopUpdates() {
        print("Background stopping updates")
        
        if (bgTimer != nil) {
            bgTimer!.invalidate()
            bgTimer = nil
        }
    }
    
    func stopWithDelay() {
        print("Background delay 50 seconds")
    }
    
    func restartUpdates() {
        print("Background restarting updates")
        
        if (bgTimer != nil) {
            bgTimer!.invalidate()
            bgTimer = nil
        }
        
        startBGTask()
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        
        startBGTask()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startBGTask() {
        // all the stuff for background tasking.
        if (bgTimer != nil) {
            return
        }
        
        let bgTask = BackgroundTaskManager.shared()
        bgTask?.beginNewBackgroundTask()
        
        // restart location manager after 1 minute
        let intervalLength = 60.0
        let delayLength = intervalLength - 10.0
        
        bgTimer = Timer.scheduledTimer(timeInterval: intervalLength, target: self, selector: #selector(ViewController.restartUpdates), userInfo: nil, repeats: false)
        
        // keep location manager inactive for 10 seconds every minute to save battery
        if (bgDelayTimer != nil) {
            bgDelayTimer!.invalidate()
            bgDelayTimer = nil
        }
        
        bgDelayTimer = Timer.scheduledTimer(timeInterval: delayLength, target: self, selector: #selector(ViewController.stopWithDelay), userInfo: nil, repeats: false)
    }

}
