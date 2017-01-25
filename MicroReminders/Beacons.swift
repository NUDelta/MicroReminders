//
//  Beacons.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/29/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation

class Beacons {
    static let sharedInstance = Beacons()
    
    // Testing
    // 59582: "romeo", 39192: "whiskey", 49825: "quebec"
    // 32706: "papa"
    let beacons: [UInt16: String] = [32706: "papa"]
    var beaconExitTimes: [UInt16: Date] = [32706: Date(timeIntervalSince1970: 0)]
    
    // No beacons
    //    var beacons: [UInt16: String] = [:]
    
    fileprivate init() {}
}
