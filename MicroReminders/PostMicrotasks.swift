//
//  PostMicrotasks.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/11/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation
import Firebase

class PostMicrotasks {

    let ref: FIRDatabaseReference! = FIRDatabase.database().reference().child("Microtasks")
    
    var microtasks = [String: NSDictionary]()
    var orders = [String: String]()
    
    init(){
        
    }
    
    // Each microtask will have an owner, completion date, context (location), description, order relative to its fellow MTs, and a completed boolean.
    func addMicrotask(owner: String, completionDate: String, context: String, description: String, order: Int, completed: Bool){
        
        let microtask = ["owner": owner, "completionDate": completionDate, "context": context, "description": description, "order": order, "completed": completed]

        let _id = NSUUID().UUIDString
        microtasks[_id] = microtask // Store each mt in a dictionary with a UUID as the key
        orders[String(order)] = _id // Store the UUIDs with their corresponding order.
    }
    
    func post() -> [String: String]{
        
        // Post individual microtasks
        for i in Array(microtasks.keys) {
            ref.child(i).setValue(microtasks[i]! as AnyObject)
        }
        
        return orders // Hand back the keys to be given to the owning task
    }
}










