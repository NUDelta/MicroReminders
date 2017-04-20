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
    static let shared: Beacons = Beacons()
    
    typealias beacons = [UInt16: String]
    private let beaconRef: FIRDatabaseReference
    
    private var _beacons: beacons?
    private var beaconExitTimes: exitTimes?
    
    func getBeacons(handler: @escaping (beacons) -> Void) {
        if (self._beacons != nil) {
            handler(self._beacons!)
        }
        else {
            self.beaconRef.observeSingleEvent(of: .value, with: { snapshot in
                let bs = snapshot.value as! beacons
                self._beacons = bs
                
                handler(self._beacons!)
            })
        }
    }
    
    func listenToBeaconRegions(beaconManager: ESTBeaconManager) {
        getBeacons(handler: { beacons in
            for minor in beacons.keys {
                beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: beacons[minor]!))
            }
        })
    }
    
    func setExitTime(forKey regionInt: UInt16, to date: Date) {
        loadExitTimes(handler: { exitTimes in
            var tmp = exitTimes
            tmp[regionInt] = date
            self.saveExitTimes(tmp)
        })
    }
    
    func getExitTime(forKey regionInt: UInt16, handler: @escaping (Date) -> Void) {
        loadExitTimes(handler: { exitTimes in
            handler(exitTimes[regionInt]!)
        })
    }
    
    func getBeaconLocation(forKey regionInt: UInt16, handler: @escaping (String) -> Void) {
        getBeacons(handler: { beacons in
            handler(beacons[regionInt]!)
        })
    }
    
    func getAllLocations(handler: @escaping ([String]) -> Void) {
        getBeacons(handler: { beacons in
            handler(Array(beacons.values))
        })
    }
    
    private func loadExitTimes(handler: @escaping (exitTimes) -> Void) {
        if let data = UserDefaults.standard.object(forKey: "beaconExitTimes") as? Data {
            let times = NSKeyedUnarchiver.unarchiveObject(with: data) as? exitTimes
            handler(times!)
        }
        else {
            getBeacons(handler: { beacons in
                let times = beacons.reduce(exitTimes(), {acc, pair in
                    var tmp = acc
                    tmp.updateValue(Date(), forKey: pair.key)
                    return tmp
                })
                self.saveExitTimes(times)
                handler(times)
            })
        }
    }
    
    private func saveExitTimes(_ exits: exitTimes) {
        let data = NSKeyedArchiver.archivedData(withRootObject: exits)
        UserDefaults.standard.set(data, forKey: "beaconExitTimes")
        UserDefaults.standard.synchronize()
    }

    
    fileprivate init() {
        let userKey = UserConfig.userKey
        let ref = FIRDatabase.database().reference()
        self.beaconRef = ref.child("UserConfig/\(userKey)/beacons")
    }
}





























