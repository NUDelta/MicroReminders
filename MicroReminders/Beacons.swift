 //
//  Beacons.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/29/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class Beacons {
    static let shared: Beacons = Beacons()
    
    typealias beacons = [UInt16: String]
    private let beaconRef: FIRDatabaseReference
    private let currRef: FIRDatabaseReference
    private var _beacons: beacons?
    private var currRegion: String?
    
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
    
    func getBeaconLocation(forKey regionInt: UInt16, handler: @escaping (String) -> Void) {
        getBeacons(handler: { beacons in
            handler(beacons[regionInt]!)
        })
    }
    
    fileprivate init() {
        let userKey = UserConfig.shared.userKey
        let ref = FIRDatabase.database().reference()
        self.beaconRef = ref.child("UserConfig").child("beacons").child("\(userKey)")
        self.currRef = ref.child("Regions").child("\(userKey)").child("current")
        self.getBeacons(handler: { _ in print("Initialized beacons...") })
    }
}





























