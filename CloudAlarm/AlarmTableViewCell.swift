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
    @IBAction func stateChanged(sender: UISwitch) {
        delegate?.alarmStateChanged(self)
    }
    
    var delegate: AlarmTableViewCellDelegate?
    
    func setValues(item: Alarm, delegate: AlarmTableViewCellDelegate, dateFormatter: NSDateFormatter) {
        self.uiSwitch.setOn(item.enabled, animated: true)
        self.label.text = item.label
        self.delegate = delegate
        self.time.text = dateFormatter.stringFromDate(item.target)
    }
}