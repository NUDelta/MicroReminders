//
//  CategoryPickerViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 11/15/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UIViewController {
    var selectedCategory: String!
    
    @IBOutlet weak var cleaningButton: UIButton!
    @IBOutlet weak var wellnessButton: UIButton!
    @IBOutlet weak var maintenanceButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    override func viewDidLoad() {
        cleaningButton.layer.cornerRadius = 5
        wellnessButton.layer.cornerRadius = 5
        maintenanceButton.layer.cornerRadius = 5
        otherButton.layer.cornerRadius = 5
    }
    
    @IBAction func cleaning_and_tidying(_ sender: UIButton) {
        selectedCategory = "Cleaning"
        self.performSegue(withIdentifier: "AddTask", sender: self)
    }
    
    @IBAction func health_and_wellness(_ sender: UIButton) {
        selectedCategory = "Wellness"
        self.performSegue(withIdentifier: "AddTask", sender: self)
    }
    
    @IBAction func house_maintenance(_ sender: UIButton) {
        selectedCategory = "Maintenance"
        self.performSegue(withIdentifier: "AddTask", sender: self)
    }
    
    @IBAction func other(_ sender: UIButton) {
        selectedCategory = "Other"
        self.performSegue(withIdentifier: "AddTask", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddTaskViewController {
            vc.taskCategory = selectedCategory
            vc.title = selectedCategory
        }
    }
}
