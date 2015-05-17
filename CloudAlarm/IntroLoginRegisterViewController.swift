//
//  IntroLoginRegisterViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class IntroLoginRegisterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var text: UITextView!
    
    let columns = ["Login", "Register"]
    var keyboardMoved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.columns.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IntroCell") as! IntroTableViewCell
        cell.field.placeholder = columns[indexPath.row]
        if indexPath.row == 1 {
            cell.field.secureTextEntry = true
        }
        return cell
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if !self.keyboardMoved {
            UIView.animateWithDuration(0.3) {
                self.view.frame = CGRectOffset(self.view.frame, 0, -self.text.frame.height - 20)
            }
            self.keyboardMoved = !self.keyboardMoved
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if self.keyboardMoved {
            UIView.animateWithDuration(0.3) {
                self.view.frame = CGRectOffset(self.view.frame, 0, self.text.frame.height + 20)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setupDone" {
            let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
            
            userDefaults!.setObject((self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! IntroTableViewCell).field.text, forKey: "mail")
            userDefaults!.setObject((self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! IntroTableViewCell).field.text, forKey: "password")
            userDefaults!.synchronize()
        }
    }
}