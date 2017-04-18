//
//  Beacons.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/29/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

typealias exitTimes = [UInt16: Date]

class Beacons {
    private static let shared: Beacons = Beacons()
    
    private var beacons: [UInt16: String] = [UInt16: String]()
    private var beaconExitTimes: exitTimes = exitTimes()
    
    static func listenToBeaconRegions(beaconManager: ESTBeaconManager) {
        for minor in shared.beacons.keys {
            beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: shared.beacons[minor]!))
        }
    }
    
    static func setExitTime(forKey regionInt: UInt16, to date: Date) {
        shared.beaconExitTimes = loadExitTimes()!
        shared.beaconExitTimes[regionInt] = date
        
        self.saveExitTimes(shared.beaconExitTimes)
    }
    
    static func getExitTime(forKey regionInt: UInt16) -> Date {
        return loadExitTimes()![regionInt]!
    }
    
    static func getBeaconLocation(forKey regionInt: UInt16) -> String {
        return shared.beacons[regionInt]!
    }
    
    static func getAllLocations() -> [String] {
        return Array(shared.beacons.values)
    }
    
    private static func loadExitTimes() -> exitTimes? {
        if let data = UserDefaults.standard.object(forKey: "beaconExitTimes") as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? exitTimes
        }
        return nil
    }
    
    private static func saveExitTimes(_ exits: exitTimes) {
        let data = NSKeyedArchiver.archivedData(withRootObject: exits)
        UserDefaults.standard.set(data, forKey: "beaconExitTimes")
        UserDefaults.standard.synchronize()
    }

    
    fileprivate init() {
        self.beacons = beaconsForUDID[userKey]!
        
        if let exits = Beacons.loadExitTimes() {
            self.beaconExitTimes = exits
        }
        else {
            self.beaconExitTimes = beacons.reduce(exitTimes(), { acc, item in
                var tmp = acc
                tmp.updateValue(Date(), forKey: item.key)
                return tmp
            })
        }
        
        Beacons.saveExitTimes(self.beaconExitTimes)
    }
}





























