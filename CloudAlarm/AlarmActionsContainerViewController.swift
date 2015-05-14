//
//  AlarmActionsContainerViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 4/25/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class AlarmActionsViewController: UITableViewController {
    
    var item: Alarm?
    
    override func viewDidLoad() {
        
   
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView?.hidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAlarmRepeatViewController" {
            let destination: AlarmRepeatViewController = segue.destinationViewController as! AlarmRepeatViewController
            
            destination.item = self.item
            
        }
    }
}