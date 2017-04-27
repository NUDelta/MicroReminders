//
//  MyHabitsTableCell.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 10/30/16.
//  Copyright © 2016 Sasha Weiss. All rights reserved.
//

import UIKit

class HabitActionCell: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var timeRange: UILabel!
    
    var tableViewController: HabitList! = nil
 
    var h_action: HabitAction! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}
