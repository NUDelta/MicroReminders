//
//  CustomTaskConstraintViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 1/23/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import UIKit
import TTRangeSlider

class CustomTaskConstraintViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var locations: [String] = Beacons.sharedInstance.beacons.values.map({ (location) in
        location.capitalized
    })
    
    var taskCategory: String!
    var pushHandler: (() -> Void)!
    
    @IBOutlet weak var taskDescription: UITextField!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var timeSlider: TTRangeSlider!
    
    override func viewDidLoad() {
        initLocationPicker()
        initTimeSlider()
    }
    
    func initTimeSlider() {
        timeSlider.numberFormatterOverride = NumberTimeFormatter() as NumberFormatter
        let sixAM = Float(12*60*60) // seconds to 6am, Jan. 1, 1970 **This is a weird number, but it works. Investigate more.
        let twoAM = Float(32*60*60) // seconds to 2am, Jan. 2, 1970 **See note above.
        let fifteenMinutes = Float(15*60) // fifteen minutes in seconds
        let oneHour = Float(60*60) // one hour in seconds
        timeSlider.minValue = sixAM
        timeSlider.maxValue = twoAM
        timeSlider.selectedMinimum = sixAM
        timeSlider.selectedMaximum = twoAM
        timeSlider.enableStep = true
        timeSlider.step = fifteenMinutes
        timeSlider.minDistance = oneHour
        
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
            
            let task = Task(UUID().uuidString, name: name, category: taskCategory, subcategory: "Personal")
            
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
