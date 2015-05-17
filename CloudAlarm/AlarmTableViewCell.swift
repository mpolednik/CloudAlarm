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
        
        var daysLabelText: String = ""
        
        let wdays: [Int: String] = [0: "Sun ", 1: "Mon ", 2: "Tue ", 3: "Wed ", 4: "Thu ", 5: "Fri ", 6: "Sat "]
        let wintervals: [Set<Int>: String] = [Set<Int>(): "No repeat", Set<Int>([0, 6]): "Weekends", Set<Int>([1, 2, 3, 4, 5]): "Work days", Set<Int>([0, 1, 2, 3, 4, 5, 6]): "Every day"]
        
        var daysArray = sorted(Array(item.repeat), {(e1: Int, e2: Int) -> Bool in e1 < e2}) as Array
        
        if item.repeat.count > 0 {
            for element in 0...item.repeat.count - 1 {
                daysLabelText += wdays[element]!
            }
        }
        
        if let interval = wintervals[item.repeat] {
            daysLabelText = interval
        }
        
        self.repeat.text = daysLabelText
        self.label.text = item.label
        self.delegate = delegate
        self.time.text = dateFormatter.stringFromDate(item.target)
    }
}