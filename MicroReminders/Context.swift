//
//  Context.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/27/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

struct LocationContext {
    enum EnterExit {
        case enter
        case exit
    }
    
    let region_name: String
    let enter_exit: EnterExit
    let delay: Double
    
    init(region: String, enter_exit: EnterExit, delay: Double) {
        self.region_name = region
        self.enter_exit = enter_exit
        self.delay = delay
    }
}

struct PlugContext {
    enum PlugUnplug {
        case plug
        case unplug
        case ignore
    }
    
    let plug_unplug: PlugUnplug
    let delay: Double
    
    init(plug_unplug: PlugUnplug, delay: Double) {
        self.plug_unplug = plug_unplug
        self.delay = delay
    }
}

struct TimeOfDayContext {
    let before: Int
    let after: Int
    
    init(before: Int, after: Int) {
        self.before = before
        self.after = after
    }
}

struct ReminderInteraction {
    enum InteractionType {
        case accepted
        case declined
        case thrown
    }
    
    let type: InteractionType
    let last: Int
    let thresh_since_last: Double
    
    init(type: InteractionType, last: Int, thresh_since_last: Double) {
        self.type = type
        self.last = last
        self.thresh_since_last = thresh_since_last
    }
}

struct PreviousInteractionsContext {
    let accepted: ReminderInteraction
    let declined: ReminderInteraction
    let thrown: ReminderInteraction
    
    init(accepted: ReminderInteraction, declined: ReminderInteraction, thrown: ReminderInteraction) {
        self.accepted = accepted
        self.declined = declined
        self.thrown = thrown
    }
}

struct Context {
    let english: String // Plain-text description of the context
    let location: LocationContext
    let plug: PlugContext
    let time: TimeOfDayContext
    let prev: PreviousInteractionsContext
    
    init(english: String, location: LocationContext, plug: PlugContext, time: TimeOfDayContext, prev: PreviousInteractionsContext) {
        self.english = english
        self.location = location
        self.plug = plug
        self.time = time
        self.prev = prev
    }
}


















