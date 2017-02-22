//
//  Goal.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/21/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

typealias Goal = (String, [Task])

enum GoalTaskState {
    case active
    case done
    case unassigned
}
