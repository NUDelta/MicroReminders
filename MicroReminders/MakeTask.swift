//
//  MakeTask.swift
//  MicroReminders first prototype
//
//  Created by Sasha Weiss on 4/5/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import Foundation

class MakeTask {
    
    var mainTask: String = ""
    
    var microTasks = [String](count: 3, repeatedValue: "")
    var locations = [String](count: 3, repeatedValue: "")
    let owner: String
    let completionDate = "4-16-1996"
    
    init(owner: String) {
        self.owner = owner
    }
    
    func setMicroTask(task: String, index: Int) {
        microTasks[index] = task
    }
    
    func setLocation(location: String, index: Int) {
        locations[index] = location
    }
    
    func setMainTask(task: String){
        mainTask = task
    }
    
    func log(){
        print("main task: \(mainTask)\ntasks: \(microTasks)\nlocations: \(locations)")
    }
    
    func post(){
        
        // Post the microtasks
        let postID = NSUUID().UUIDString // create a post with unique ID
        let post = PostTask(_id: postID)
        let postMTs = PostMicrotasks()
        
        for i in 0...microTasks.count-1 {
            postMTs.addMicrotask(postID, completionDate: completionDate, context: locations[i], description: microTasks[i], order: i, completed: false)
        }
        let _mt_ids = postMTs.post() // get MT ids
        
        
        // Post the actual task
        post.post(owner, completionDate: completionDate, description: mainTask, completed: false, microtasks: _mt_ids, step: 0)
    }
}












