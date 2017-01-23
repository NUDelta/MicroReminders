//
//  TaskConstraintViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 1/20/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import UIKit
import TTRangeSlider

class TaskConstraintViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var locations: [String] = Beacons.sharedInstance.beacons.values.map({ (location) in
        location.capitalized
    })
    
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var whereSwitch: UISwitch!
    
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
        timeSlider.minValue = sixAM
        timeSlider.maxValue = twoAM
        timeSlider.selectedMinimum = sixAM
        timeSlider.selectedMaximum = twoAM
        timeSlider.enableStep = true
        timeSlider.step = fifteenMinutes
    }
    
    func initLocationPicker() {
        locationPicker.delegate = self
        locationPicker.dataSource = self
    }
    
    @IBAction func addTaskClicked(_ sender: UIButton) {
        print("no")
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

class NumberTimeFormatter: NumberFormatter {
    override func string(for obj: Any?) -> String? {
        if (!(obj is NSNumber)) {
            return nil
        }
        
        let dateTime = Date(timeIntervalSince1970: (obj as! NSNumber).doubleValue)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "h:mm a"
        
        return formatter.string(from: dateTime)
    }
}
