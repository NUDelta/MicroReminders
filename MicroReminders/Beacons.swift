//
//  Beacons.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/29/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class Beacons: NSObject, NSCoding {
    static let sharedInstance = Beacons()
    
    var beacons = [UInt16: String]() {
        didSet {
            beaconListeners.forEach({ $1() })
        }
    }
    var beaconExitTimes = [UInt16: Date]()
    var beaconListeners = [String: () -> Void]()
    
    static func beaconsFromCodeword(codeword: String) {
        /**
         This gets called on segue from the intro view controller, and then state gets saved in UserDefaults.
         */
        
        let beaconRef = FIRDatabase.database().reference().child("Beacons/\(codeword)")
        
        beaconRef.observeSingleEvent(of: .value, with: { snapshot in
            let stringBeacons = snapshot.value as! [String: String]
            self.sharedInstance.beacons = stringBeacons.reduce([UInt16: String](), { (acc, e) in
                var copy = acc
                copy[UInt16(e.key)!] = e.value
                return copy
            })
            
            self.sharedInstance.beaconExitTimes = self.sharedInstance.beacons.keys.reduce([UInt16: Date](), { (acc, e) in
                var copy = acc
                copy[e] = Date(timeIntervalSince1970: 0)
                return copy
            })
            
            self.saveBeacons()
        })
    }
    
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
        self.beaconListeners = decoder.decodeObject(forKey: "beaconListeners") as! [String: () -> Void]
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(beacons, forKey: "beacons")
        coder.encode(beaconExitTimes, forKey: "beaconExitTimes")
        coder.encode(beaconListeners, forKey: "beaconListeners")
    }
    
    fileprivate override init() { super.init() }
}
