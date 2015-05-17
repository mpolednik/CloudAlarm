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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.columns.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IntroCell") as! IntroTableViewCell
        cell.field.placeholder = columns[indexPath.row]
        return cell
    }
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animateWithDuration(0.3) {
            self.view.frame = CGRectOffset(self.view.frame, 0, -self.text.frame.height - 20)
        }
        println("test")
    }
}