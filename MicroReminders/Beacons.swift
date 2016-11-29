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
    // let beacons: [UInt16: String] = [59582: "bedroom", 39192: "kitchen", 49825: "living room"]
    // var beaconExitTimes: [UInt16: Date] = [59582: Date(timeIntervalSince1970: 0), 39192: Date(timeIntervalSince1970: 0), 49825: Date(timeIntervalSince1970: 0)]
    
    // Katie
    // 7152: "zeus", 35710: "delta", 41424: "hotel"
    let beacons: [UInt16: String] = [7152: "car", 35710: "kitchen", 41424: "bedroom"]
    var beaconExitTimes: [UInt16: Date] = [7152: Date(timeIntervalSince1970: 0), 35710: Date(timeIntervalSince1970: 0), 49825: Date(timeIntervalSince1970: 0)]
    
    // No beacons
    //    var beacons: [UInt16: String] = [:]
    
    fileprivate init() {}
}
