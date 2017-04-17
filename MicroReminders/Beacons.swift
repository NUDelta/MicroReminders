//
//  Beacons.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/29/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

fileprivate let beaconsForUDID: [String: [UInt16: String]] = [
    UIDevice.current.identifierForVendor!.uuidString: [/* insert testing beacon info here */:]/*,
    insert other user's UDIDs and beacon info here */
]

class Beacons: NSObject, NSCoding {
    static let sharedInstance = Beacons()
    
    var beacons: [UInt16: String] = beaconsForUDID[UIDevice.current.identifierForVendor!.uuidString]!
    var beaconExitTimes = [UInt16: Date]()
    
    static func listenToBeaconRegions(beaconManager: ESTBeaconManager) {
        let beacons = sharedInstance.beacons
        for minor in beacons.keys {
            beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: beacons[minor]!))
        }
    }
    
    static func setExitTime(forKey regionInt: UInt16, to date: Date) {
        sharedInstance.beaconExitTimes[regionInt] = date
        
        self.saveBeacons()
    }
    
    static func loadBeacons() -> Beacons? {
        return UserDefaults.standard.object(forKey: "beacons") as? Beacons
    }
    
    static func saveBeacons() {
        UserDefaults.standard.set(Beacons.sharedInstance, forKey: "beacons")
        UserDefaults.standard.synchronize()
    }
    
    required init(coder decoder: NSCoder) {
        self.beacons = decoder.decodeObject(forKey: "beacons") as! [UInt16: String]
        self.beaconExitTimes = decoder.decodeObject(forKey: "beaconExitTimes") as! [UInt16: Date]
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(beacons, forKey: "beacons")
        coder.encode(beaconExitTimes, forKey: "beaconExitTimes")
    }
    
    fileprivate override init() { super.init() }
}





























