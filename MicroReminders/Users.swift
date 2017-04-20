//
//  Users.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/18/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

let userKey = "yk" // testing iPhone

let beaconsForUDID: [String: [UInt16: String]] = [
    "delta": [39192: "whiskey", 59582: "romeo"],
    "kap": [39192: "whiskey", 59582: "romeo"],
    "yk": [39192: "whiskey", 59582: "romeo"]
    /* insert other user's UDIDs and beacon info here */
]

let renotifyThreshold: [String: Double] = [
    "delta": 0.1,
    "kap": 1,
    "yk": 1
    /* insert other user's preferred renotification threshold times (minutes) here */
]
