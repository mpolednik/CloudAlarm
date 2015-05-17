//
//  SettingsViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITableViewDataSource {
    
    @IBOutlet weak var username: UITableViewCell!
    @IBOutlet weak var bridge: UITableViewCell!
    
    override func viewDidLoad() {
        let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
        
        let mail: String? = userDefaults!.valueForKey("mail") as! String?
        if let mail = mail {
            self.username.textLabel!.text = mail
        } else {
            self.username.textLabel!.text = "Not set"
        }
        let hueIp: String? = userDefaults!.valueForKey("hueIp") as! String?
        let hueMac: String? = userDefaults!.valueForKey("hueMac") as! String?
        
        if let ip = hueIp, mac = hueMac {
            bridge.textLabel!.text = ip
            bridge.detailTextLabel!.text = mac
        } else {
            bridge.textLabel!.text = "Not set"
        }
    }
}