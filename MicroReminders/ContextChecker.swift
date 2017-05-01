//
//  ContextChecker.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 4/27/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

/** Perform checks to see if we have h_actions that should be reminded right now.
 
 All checking is initiated by entrance/exiting of a region.
 */
class ContextChecker {
    
    /** Get potential tasks in response to a region change. */
    fileprivate func availableForRegionChange(_ h_action: HabitAction, reg: String, dir: LocationContext.EnterExit) -> Bool {
        let lc = h_action.context.location
        
        let reg_match = lc.region_name == reg
        let dir_match = lc.enter_exit == dir
        
        return reg_match && dir_match
    }
    
    fileprivate func availableForRegionChange(_ h_actions: [HabitAction], reg: String, dir: LocationContext.EnterExit) -> [HabitAction] {
        return h_actions.filter({ ha in
            return availableForRegionChange(ha, reg: reg, dir: dir)
        })
    }
    
    /** Check if timeOfDay falls in the h_action's time context.
 
     timeOfDay represents seconds into the day.
     */
    fileprivate func availableAtTimeOfDay(_ h_action: HabitAction, timeOfDay: Int) -> Bool {
        let tc = h_action.context.time
        
        let before = timeOfDay < tc.before
        let after = timeOfDay > tc.after
        
        return before && after
    }
    
    fileprivate func availableAtTimeOfDay(_ h_actions: [HabitAction], timeOfDay: Int) -> [HabitAction] {
        return h_actions.filter({ ha in
            return availableAtTimeOfDay(ha, timeOfDay: timeOfDay)
        })
    }
    
    /** Filter h_actions for those that are available based on their recent previous interactions */
    fileprivate func immediatelyAvailableFromPreviousInteractions(_ h_actions: [HabitAction]) -> [HabitAction] {
        let rn = timeSince1970InSeconds()
        
        return h_actions.filter({ ha in
            let prev = ha.context.prev
            
            let thrown = (prev.thrown.last + prev.thrown.thresh_since_last) < rn
            let accepted = (prev.accepted.last + prev.accepted.thresh_since_last) < rn
            let declined = (prev.declined.last + prev.declined.thresh_since_last) < rn
            
            return thrown && accepted && declined
        })
    }
    
    /** Filter h_actions for those whose context does not depend on a plug event */
    fileprivate func noPlugContext(_ h_actions: [HabitAction]) -> [HabitAction] {
        return h_actions.filter({ ha in
            return ha.context.plug.plug_unplug == .ignore
        })
    }
    
    /** Filter h_actions to determine if any are available for notification as soon as a region movement occurs. */
    func immediatelyAvailableUponRegionChange(_ h_actions: [HabitAction], dir: LocationContext.EnterExit, reg: String) -> [HabitAction] {
        
        let loc_avail = availableForRegionChange(h_actions, reg: reg, dir: dir) // Good for region
        let time_avail = availableAtTimeOfDay(loc_avail, timeOfDay: offsetIntoTodayInSeconds()) // Good for right now
        let prev_avail = immediatelyAvailableFromPreviousInteractions(time_avail) // Past all thresholds
        let no_plug = noPlugContext(prev_avail) // Not tied to a plug event
        
        return no_plug
    }
}

/** Check if any tasks with delays would be available at the end of the delay.
 
 Delays can be after a region movement or plug event, and must finish inside the time range.
 */
extension ContextChecker {
    
    /** Finds actions that will be available after a location delay.
     
     Assumes location does not change during delay (Delayer must enforce).
     */
    func willBeAvailableAfterLocationDelay(_ h_actions: [HabitAction]) -> [HabitAction] {
        let has_delay = h_actions.filter({ ha in
            return ha.context.location.delay > 0
        })
        
        let offset = offsetIntoTodayInSeconds()
        return has_delay.filter({ ha in
            let tod = offset + ha.context.location.delay
            
            return availableAtTimeOfDay(ha, timeOfDay: tod)
        })
    }
    
    /** Finds actions that have plug context, so we can delay on entrance until the plug */
    private func hasPlugContext(_ h_actions: [HabitAction]) -> [HabitAction] {
        return h_actions.filter({ ha in
            return ha.context.plug.plug_unplug != .ignore
        })
    }
    
    /** Finds actions that will be available after a delay from a plug event at fromTime */
    func willBeAvailableAfterPlugDelay(_ h_actions: [HabitAction], fromTime: Int) -> [HabitAction] {
        let offset = offsetIntoTodayInSeconds()
        return hasPlugContext(h_actions).filter({ ha in
            let tod = offset + ha.context.plug.delay
            
            return availableAtTimeOfDay(ha, timeOfDay: tod)
        })
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
















