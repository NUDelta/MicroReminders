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
    
    func setLastInteraction(of type: ReminderInteraction.InteractionType, to value: Double, with handler: (() -> Void)!) -> Void {
        let ref = FIRDatabase.database().reference()
            .child("Habits/\(UserConfig.shared.userKey)/\(self.habit)/\(self.description)/prev_interactions")
        
        var ref_adj: FIRDatabaseReference
        switch type {
        case .accepted:
            ref_adj = ref.child("accepted/last")
            break
        case .declined:
            ref_adj = ref.child("declined/last")
            break
        case .thrown:
            ref_adj = ref.child("thrown/last")
            break
        }
        
        ref_adj.setValue(value, withCompletionBlock: { _ in handler() })
    }
}






















