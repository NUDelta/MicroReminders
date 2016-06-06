//
//  Utilities.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 5/19/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation

func date_to_string() -> String {
    let date = NSDate()
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
    dateFormatter.dateStyle = .MediumStyle
    dateFormatter.timeStyle = .MediumStyle
    return dateFormatter.stringFromDate(date)
}