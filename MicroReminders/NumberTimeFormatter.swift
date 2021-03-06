//
//  TimeNumberFormatter.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 1/23/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import UIKit

class NumberTimeFormatter: NumberFormatter {
    override func string(for obj: Any?) -> String? {
        if (!(obj is NSNumber)) {
            return nil
        }
        
        let cal = Calendar.current
        
        let dateTime = Date(timeIntervalSince1970: (obj as! NSNumber).doubleValue)
        let sixHours = DateComponents(hour: 6)
        
        let adjustedTime = cal.date(byAdding: sixHours, to: dateTime)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: adjustedTime!)
    }
}
