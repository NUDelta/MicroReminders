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
    static let sharedInstance = Beacons()
    
    var beacons = [UInt16: String]() {
        didSet {
            self.beaconExitTimes = self.beacons.keys.reduce([UInt16: Date](), { (acc, e) in
                var copy = acc
                copy[e] = Date(timeIntervalSince1970: 0)
                return copy
            })
            
            beaconListeners.forEach({ $1() })
        }
    }
    var beaconExitTimes = [UInt16: Date]()
    var beaconListeners = [String: (() -> Void)]()
    
    func beaconsFromCodeword(handler: (() -> Void)! = nil) {
        if let codeword = UserDefaults.standard.object(forKey: "beaconCodeword") as? String {
            let beaconRef = FIRDatabase.database().reference().child("Beacons/\(codeword)")
            
            beaconRef.observeSingleEvent(of: .value, with: { snapshot in
                let stringBeacons = snapshot.value as! [String: String]
                self.beacons = stringBeacons.reduce([UInt16: String](), { (acc, e) in
                    var copy = acc
                    copy[UInt16(e.key)!] = e.value
                    return copy
                })
                
                if handler != nil {
                    handler()
                }
            })
        }
    }
    
    fileprivate init() {}
}
