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
    let beacons: [UInt16: String] = [59582: "kitchen", 39192: "fireplace", 49825: "bathroom"]
    var beaconExitTimes: [UInt16: Date] = [59582: Date(timeIntervalSince1970: 0), 39192: Date(timeIntervalSince1970: 0), 49825: Date(timeIntervalSince1970: 0)]
    
    // var beacons: [UInt16: String] = [59582: "romeo"]
    // var beacons: [UInt16: String] = [39192: "whiskey"]
    // var beacons: [UInt16: String] = [49825: "quebec"]
    
    // No beacons
    //    var beacons: [UInt16: String] = [:]
    
    fileprivate init() {}
}
