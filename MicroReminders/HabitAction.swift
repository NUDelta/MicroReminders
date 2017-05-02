//
//  HabitAction.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/22/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Firebase

class HabitAction {
    
    let description: String
    let habit: String
    let context: Context
    
    init(_ description: String, habit: String, context: Context) {
        self.description = description
        self.habit = habit
        self.context = context
    }
    
    static func setLastInteraction(of type: ReminderInteraction.InteractionType,
                                   withHabit habit: String,
                                   withAction description: String,
                                   to value: Int,
                                   with handler: (() -> Void)?) -> Void {
        let ref = FIRDatabase.database().reference()
            .child("Habits/\(UserConfig.shared.userKey)/\(habit)/\(description)/prev_interactions")
        
        var ref_adj: FIRDatabaseReference
        switch type {
        case .accepted:
            ref_adj = ref.child("accepted").child("last")
            break
        case .declined:
            ref_adj = ref.child("declined").child("last")
            break
        case .thrown:
            ref_adj = ref.child("thrown").child("last")
            break
        }
        
        ref_adj.setValue(value, withCompletionBlock: { _ in
            if (handler != nil) {
                handler!()
            }
        })
    }
}






















