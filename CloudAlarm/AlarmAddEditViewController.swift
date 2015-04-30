//
//  AlarmAddEditViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 4/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class AlarmAddEditViewController: UIViewController {
    
    @IBOutlet weak var label: UITextField!
    @IBOutlet weak var timepicker: UIDatePicker!
    
    var item: Alarm?
    var edit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let alarm = self.item where edit {
            self.label.text = alarm.label
            self.timepicker.date = alarm.target
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedAlarmActionsViewController" {
            let destination: AlarmActionsViewController = segue.destinationViewController as! AlarmActionsViewController
            destination.item = self.item
        }
    }
    
    @IBAction func alarmTargetChanged(sender: UIDatePicker) {
        if let alarm = self.item {
            alarm.target = sender.date
        }
    }
    
    @IBAction func alarmLabelChanged(sender: UITextField) {
        if let alarm = self.item {
            alarm.label = sender.text
        }
    }
}