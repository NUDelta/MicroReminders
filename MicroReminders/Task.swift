//
//  Task.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/22/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

struct Task {
    let _id: String
    let name: String
    let category1: String
    let category2: String
    let category3: String
    let mov_sta: String
    
    init(_ _id: String, _ name: String, _ category1: String, _ category2: String, _ category3: String, _ mov_sta: String) {
        self._id = _id
        self.name = name
        self.category1 = category1
        self.category2 = category2
        self.category3 = category3
        self.mov_sta = mov_sta
    }
}