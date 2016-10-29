//
//  Beacons.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/29/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

class Beacons {
    static let sharedInstance = Beacons()
    
    // ADEL
    //    var beacons: [UInt16: String] = [53805: "bike", 41424: "bedroom", 35710: "helens apartment"]
    // hotel (bedroom): 41424
    // bravo (bike): 53805
    // delta (helens apartment): 35710
    
    // HELEN
    //    var beacons: [UInt16: String] = [34944: "car", 62318: "living room", 44363: "bedroom"]
    // tango (car): 34944
    // uniform (living room): 62318
    // victor (bedroom): 44363
    
    // BILL
    //    var beacons: [UInt16: String] = [32706: "bedroom", 58574: "suite lounge"]
    // papa (bedroom): 32706
    // alpha (suite lounge): 58574
    // india (AG52): 30885
    
    // ME/Max
    let beacons: [UInt16: String] = [59582: "kitchen", 39192: "fireplace", 49825: "bathroom"]
    // var beacons: [UInt16: String] = [59582: "romeo"]
    // var beacons: [UInt16: String] = [39192: "whiskey"]
    // var beacons: [UInt16: String] = [49825: "quebec"]
    
    // No beacons
    //    var beacons: [UInt16: String] = [:]

    
    private init() {}
}