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
    let beacons: [UInt16: String] = [59582: "bedroom", 39192: "kitchen", 49825: "living room"]
    var beaconExitTimes: [UInt16: Date] = [59582: Date(timeIntervalSince1970: 0), 39192: Date(timeIntervalSince1970: 0), 49825: Date(timeIntervalSince1970: 0)]
    
    // Katie
    // 7152: "zeus", 35710: "delta", 41424: "hotel"
    // let beacons: [UInt16: String] = [7152: "car", 35710: "kitchen", 41424: "bedroom"]
    // var beaconExitTimes: [UInt16: Date] = [7152: Date(timeIntervalSince1970: 0), 35710: Date(timeIntervalSince1970: 0), 49825: Date(timeIntervalSince1970: 0)]
    
    // Kapil
    // 56913: "zelda", 62318: "uniform", 13033: "zara"
    // let beacons: [UInt16: String] = [56913: "bedroom", 62318: "kitchen", 13033: "bathroom"]
    // var beaconExitTimes: [UInt16: Date] = [56913: Date(timeIntervalSince1970: 0), 62318: Date(timeIntervalSince1970: 0), 13033: Date(timeIntervalSince1970: 0)]
    
    // Helen
    // 27990: "golf", 47788: "zach", 58574: "alpha"
    // let beacons: [UInt16: String] = [27990: "adel's room", 47788: "my bedroom", 58574: "car"]
    // var beaconExitTimes: [UInt16: Date] = [27990: Date(timeIntervalSince1970: 0), 47788: Date(timeIntervalSince1970: 0), 58574: Date(timeIntervalSince1970: 0)]
    
    // Noah
    // 1471: "xray", 32706: "papa", 44363: "victor"
    // let beacons: [UInt16: String] = [1471: "car", 32706: "kitchen", 44363: "bedroom"]
    // var beaconExitTimes: [UInt16: Date] = [1471: Date(timeIntervalSince1970: 0), 32706: Date(timeIntervalSince1970: 0), 44363: Date(timeIntervalSince1970: 0)]

    
    // No beacons
    //    var beacons: [UInt16: String] = [:]
    
    fileprivate init() {}
}
