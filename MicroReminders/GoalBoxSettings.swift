//
//  GoalBoxSettings.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/21/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

class GoalBoxSettings {
    private init() {}
    static let sharedInstance = GoalBoxSettings()
    
    let height = CGFloat(100)
//    let color = UIColor.cyan
    let color = UIColor(red: 0xCC/255.0, green: 0xCC/255.0, blue: 1, alpha: 1)
    let cornerRadius = CGFloat(5)
}
