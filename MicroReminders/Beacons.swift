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
    
    private let exitTimeRef: FIRDatabaseReference
    private var beaconExitTimes: exitTimes?
    
    func getBeacons(handler: @escaping (beacons) -> Void) {
        if (self._beacons != nil) {
            handler(self._beacons!)
        }
        else {
            self.beaconRef.observeSingleEvent(of: .value, with: { snapshot in
                // It comes back from Firebase as a string dictionary, so
                // this stuff is necessary. Working theory is that it's because
                // I push it up as a JSON where the keys are strings.
                let tmp = snapshot.value as! [String: String]
                let bs = tmp.reduce(beacons(), { acc, pair in
                    var _tmp = acc
                    _tmp.updateValue(pair.value, forKey: UInt16(pair.key)!)
                    return _tmp
                })
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
        if (self.beaconExitTimes != nil) {
            // If we have exit times already loaded
            handler(self.beaconExitTimes!)
        }
        else {
            exitTimeRef.observeSingleEvent(of: .value, with: { snapshot in
                // If we have times in Firebase but not locally
                if let times = snapshot.value as? [String: Double] {
                    self.beaconExitTimes = times.reduce(exitTimes(), { acc, pair in
                        var tmp = acc
                        tmp.updateValue(Date(timeIntervalSince1970: pair.value), forKey: UInt16(pair.key)!)
                        return tmp
                    })
                    handler(self.beaconExitTimes!)
                }
                else {
                    // If this is the first time we are loading times
                    self.getBeacons(handler: { beacons in
                        self.beaconExitTimes = beacons.reduce(exitTimes(), { acc, pair in
                            var tmp = acc
                            tmp.updateValue(Date(timeIntervalSince1970: 0), forKey: pair.key)
                            return tmp
                        })
                        self.saveExitTimes(self.beaconExitTimes!)
                        handler(self.beaconExitTimes!)
                    })
                }
            })
        }
    }
    
    private func saveExitTimes(_ exits: exitTimes) {
        // Save exit times locally
        self.beaconExitTimes = exits
        
        // Save exit times to Firebase
        let times: [String: Double] = exits.reduce([String: Double](), { acc, pair in
            var tmp = acc
            tmp.updateValue(pair.value.timeIntervalSince1970, forKey: String(pair.key))
            return tmp
        })
        
        self.exitTimeRef.setValue(times)
    }

    
    fileprivate init() {
        let userKey = UserConfig.shared.userKey
        let ref = FIRDatabase.database().reference()
        self.beaconRef = ref.child("UserConfig/beacons/\(userKey)")
        self.exitTimeRef = ref.child("BeaconExitTimes/\(userKey)")
    }
}





























