//
//  ContextChecker.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/27/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

/** Find actions legal immediately after a region change */
class ContextChecker {
    
    /** Get potential tasks in response to a region change. */
    fileprivate func availableForRegionChange(_ h_action: HabitAction, reg: String, dir: LocationContext.EnterExit) -> Bool {
        let dir_match = h_action.context.location.enter_exit == dir
        
        return legalLocation(h_action, loc: reg) && dir_match
    }
    
    fileprivate func availableForRegionChange(_ h_actions: [HabitAction], reg: String, dir: LocationContext.EnterExit) -> [HabitAction] {
        return h_actions.filter({ ha in
            return availableForRegionChange(ha, reg: reg, dir: dir)
        })
    }
    
    fileprivate func availableAtTimeOfDay(_ h_actions: [HabitAction]) -> [HabitAction] {
        return h_actions.filter({ ha in
            return legalTOD(ha)
        })
    }
    
    /** Filter h_actions for those that are available based on their recent previous interactions */
    fileprivate func immediatelyAvailableFromPreviousInteractions(_ h_actions: [HabitAction]) -> [HabitAction] {
        return h_actions.filter({ ha in
            return legalWRTPreviousInteractions(ha)
        })
    }
    
    /** Filter h_actions for those whose context does not depend on a plug event */
    fileprivate func noPlugContext(_ h_actions: [HabitAction]) -> [HabitAction] {
        return h_actions.filter({ ha in
            return !hasPlugContext(ha)
        })
    }
    
    /** Filter h_actions to determine if any are available for notification as soon as a region movement occurs. */
    func immediatelyAvailableUponRegionChange(_ h_actions: [HabitAction], dir: LocationContext.EnterExit, reg: String) -> [HabitAction] {
        
        let loc_avail = availableForRegionChange(h_actions, reg: reg, dir: dir) // Good for region
        let time_avail = availableAtTimeOfDay(loc_avail) // Good for right now
        let prev_avail = immediatelyAvailableFromPreviousInteractions(time_avail) // Past all thresholds
        let no_plug = noPlugContext(prev_avail) // Not tied to a plug event
        
        return no_plug
    }
}

/** Check for tasks that get passed off to BackgroundSenser */
extension ContextChecker {
    
    /** Finds actions that have a location delay */
    func hasLocationDelay(_ h_actions: [HabitAction], for loc: String) -> [HabitAction] {
        return h_actions.filter({ ha in
            return legalLocation(ha, loc: loc) && hasLocationDelay(ha)
        })
    }
    
    /** Finds actions that have plug context with or w/o delay */
    func hasPlug(_ h_actions: [HabitAction], at loc: String, withDelay: Bool) -> [HabitAction] {
        let plugs = h_actions.filter({ ha in
            return legalLocation(ha, loc: loc) && hasPlugContext(ha)
        })
        
        return withDelay ?
            plugs.filter({ ha in
                hasPlugDelay(ha)
            }) : plugs.filter({ ha in
                !hasPlugDelay(ha)
            })
    }
}

/** Check aspects of context */
extension ContextChecker {
    
    /** Check location is legal */
    func legalLocation(_ h_action: HabitAction, loc: String) -> Bool {
        return h_action.context.location.region_name == loc
    }
    
    /** Check TOD is legal right now */
    func legalTOD(_ h_action: HabitAction) -> Bool {
        let tc = h_action.context.time
        let timeOfDay = offsetIntoTodayInSeconds()
        
        let before = timeOfDay < tc.before
        let after = timeOfDay > tc.after
        
        return before && after
    }
    
    /** Check time is legal WRT previous interactions */
    func legalWRTPreviousInteractions(_ h_action: HabitAction) -> Bool {
        let rn = timeSince1970InSeconds()
        
        let prev = h_action.context.prev
        
        let thrown = (prev.thrown.last + prev.thrown.thresh_since_last) < rn
        let accepted = (prev.accepted.last + prev.accepted.thresh_since_last) < rn
        let declined = (prev.declined.last + prev.declined.thresh_since_last) < rn
        
        return thrown && accepted && declined
    }
    
    func hasPlugContext(_ h_action: HabitAction) -> Bool {
        return h_action.context.plug.plug_unplug != .ignore
    }
    
    func hasPlugDelay(_ h_action: HabitAction) -> Bool {
        return h_action.context.plug.delay > 0
    }
    
    func hasLocationDelay(_ h_action: HabitAction) -> Bool {
        return h_action.context.location.delay > 0
    }
}

/** Time-getting utilities */
extension ContextChecker {
    fileprivate func offsetIntoTodayInSeconds() -> Int {
        let cal = Calendar.current
        
        let twoAM = 2 * 60 * 60
        let twentyFourHours = 24 * 60 * 60
        
        let seconds = Int(Date().timeIntervalSince(cal.startOfDay(for: Date())))
        
        return seconds < twoAM ? seconds + twentyFourHours : seconds
    }
    
    fileprivate func timeSince1970InSeconds() -> Int {
        let now = Date()
        
        return Int(now.timeIntervalSince1970)
    }
}
















