//
//  AlarmCell.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 4/24/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

protocol AlarmTableViewCellDelegate {
    func alarmStateChanged(cell: AlarmTableViewCell)
}

class AlarmTableViewCell: UITableViewCell {
    
    @IBOutlet weak var uiSwitch: UISwitch!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var repeat: UILabel!
    @IBAction func stateChanged(sender: UISwitch) {
        delegate?.alarmStateChanged(self)
    }
    
    var delegate: AlarmTableViewCellDelegate?
    
    func setValues(item: Alarm, delegate: AlarmTableViewCellDelegate, dateFormatter: NSDateFormatter) {
        self.uiSwitch.setOn(item.enabled, animated: true)
        
        var daysLabelText:String = ""
        
        var count = item.repeat.count
        
        let wdays: [Int: String] = [0: "Sun ", 1: "Mon ", 2: "Tue ", 3: "Wed ", 4: "Thu ", 5: "Fri ", 6: "Sat "]
        
        var daysArray = sorted(Array(item.repeat), {(e1: Int, e2: Int) -> Bool in e1 < e2}) as Array
        
        if count > 0 {
            for  element in 0...count-1 {
                daysLabelText += wdays[daysArray[element]]!
            }
        }
        
        if count == 2
        {
            if (daysArray[0] == 0 && daysArray[1] == 6) {
                daysLabelText = "Weekends"
            }
        }
        
        if count == 5
        {
            if (daysArray[0] == 1 && daysArray[1] == 2 && daysArray[2] == 3 && daysArray[3] == 4 && daysArray[4] == 5 ) {
                daysLabelText = "Work days"
            }
        }
        
        if count == 7
        {
            daysLabelText = "Every day"
        }
        
        if daysLabelText == "" {
            daysLabelText = "No repeat"
        }
        
        var repeatString:String = ""
        for days in item.repeat {
            repeatString += String(days) + " "
        }
        self.repeat.text = daysLabelText
        self.label.text = item.label
        self.delegate = delegate
        self.time.text = dateFormatter.stringFromDate(item.target)
    }
}