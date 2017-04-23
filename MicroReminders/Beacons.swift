 //
//  Beacons.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/29/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

typealias exitTimes = [UInt16: Date]

class Beacons {
    static let shared: Beacons = Beacons()
    
    typealias beacons = [UInt16: String]
    private let beaconRef: FIRDatabaseReference
    private var _beacons: beacons?
    
    private var _okayToNotify: [UInt16: Bool]?
    
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
    
    func listenToBeaconRegions(beaconManager: ESTBeaconManager) {
        beaconManager.stopMonitoringForAllRegions()
        getBeacons(handler: { beacons in
            for minor in beacons.keys {
                beaconManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5625, minor: minor, identifier: beacons[minor]!))
            }
        })
    }
    
    func okayToNotify(for region: UInt16, handler: @escaping (Bool) -> Void) {
        self.getBeacons(handler: { bs in
            
            // True for each of our beacon values
            self._okayToNotify = bs.reduce([UInt16: Bool](), { acc, pair in
                var tmp = acc
                tmp.updateValue(true, forKey: pair.key)
                return tmp
            })
            
            // False if we have a "do not notify" notification waiting around
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
                for request in requests {
                    if let key = UInt16(request.identifier) {
                        // If this request has a beacon ID as its identifier
                        if (bs[key] != nil) {
                            // If this beacon ID is one of our active beacons
                            self._okayToNotify![key] = false
                        }
                    }
                }
                
                handler(self._okayToNotify![region]!)
            })
        })
    }
    
    fileprivate init() {
        let userKey = UserConfig.shared.userKey
        let ref = FIRDatabase.database().reference()
        self.beaconRef = ref.child("UserConfig/beacons/\(userKey)")
    }
}





























