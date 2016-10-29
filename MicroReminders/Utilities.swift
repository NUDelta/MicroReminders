//
//  Utilities.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 5/19/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation

func date_to_string() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter.string(from: date)
}
