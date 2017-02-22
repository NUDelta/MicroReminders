//
//  CustomTaskConstraintViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 1/23/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import UIKit
import TTRangeSlider

class CustomTaskConstraintViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var locations: [String] = Beacons.sharedInstance.beacons.values.map({ $0.capitalized })
    
    var goal: Goal!
    var pushHandler: (() -> Void)!
    
    var existingTask: Task! // Are we modifying an existing task? e.g. reactivating, assigning prepopulated
    var newTaskId: String!
    
    @IBOutlet weak var taskDescription: UITextField!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var timeSlider: TTRangeSlider!
    
    override func viewDidLoad() {
        initLocationPicker()
        initTimeSlider()
        initTextField()
        initBasedOnExistingTask()
    }
    
    func initBasedOnExistingTask() {
        if (existingTask != nil) {
            self.newTaskId = existingTask!._id
            
            taskDescription.text = existingTask!.name
        }
        else {
            self.newTaskId = UUID().uuidString
        }
    }
    
    func initTextField() {
        taskDescription.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func initTimeSlider() {
        timeSlider.numberFormatterOverride = NumberTimeFormatter() as NumberFormatter
        
        let cal = Calendar.current
        let epoch = Date(timeIntervalSince1970: 0)
        
        let startOfDay = cal.startOfDay(for: Date())
        let sixHours = DateComponents(hour: 6)
        let twentySixHours = DateComponents(hour: 26)
        let sixAM = cal.date(byAdding: sixHours, to: startOfDay)
        let twoAM = cal.date(byAdding: twentySixHours, to: startOfDay)
        
        let step = DateComponents(minute: 15)
        let spacing = DateComponents(hour: 1)
        
        timeSlider.minValue = Float(sixAM!.timeIntervalSince(epoch) - startOfDay.timeIntervalSince(epoch))
        timeSlider.maxValue = Float(twoAM!.timeIntervalSince(epoch) - startOfDay.timeIntervalSince(epoch))
        
        timeSlider.selectedMinimum = timeSlider.minValue
        timeSlider.selectedMaximum = timeSlider.maxValue
        timeSlider.enableStep = true
        timeSlider.step = Float(cal.date(byAdding: step, to: epoch)!.timeIntervalSince1970)
        timeSlider.minDistance = Float(cal.date(byAdding: spacing, to: epoch)!.timeIntervalSince1970)
        
        timeSlider.tintColor = UIColor.darkGray
        timeSlider.tintColorBetweenHandles = UIColor.blue
        timeSlider.handleColor = UIColor.blue
        timeSlider.minLabelColour = UIColor.blue
        timeSlider.maxLabelColour = UIColor.blue
        timeSlider.lineHeight = 3.0
    }
    
    func initLocationPicker() {
        locationPicker.delegate = self
        locationPicker.dataSource = self
    }
    
    @IBAction func addTaskClicked(_ sender: UIButton) {
        let name = taskDescription.text!
        if name != "" {
            let location = locations[locationPicker.selectedRow(inComponent: 0)]
            let beforeTime = String(timeSlider.selectedMaximum)
            let afterTime = String(timeSlider.selectedMinimum)
            
            let task = Task(newTaskId!, name: name, goal: goal!.0, order: "-1")
            
            task.location = location
            task.beforeTime = beforeTime
            task.afterTime = afterTime
            
            task.pushToFirebase(handler: pushHandler)
        }
        else {
            let alert = UIAlertController(title: "Please enter a task!", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locations.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locations[row]
    }
}
