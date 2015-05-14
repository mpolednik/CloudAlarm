//
//  AlarmRepeatViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 4/25/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class AlarmRepeatViewController: UITableViewController {
    
    let days: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var item: Alarm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView?.hidden = true
        
        if let alarm = self.item {
            for day in alarm.repeat {
                self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: day, inSection: 0), animated: false, scrollPosition: .None)
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("RepeatCell") as! UITableViewCell
        cell.textLabel!.text = days[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.item!.repeat.insert(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let index = find(self.item!.repeat, indexPath.row) {
            self.item!.repeat.remove(indexPath.row)
        }
    }
}