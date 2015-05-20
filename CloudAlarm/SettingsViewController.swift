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
        self.refresh()
    }
    
    func refresh() {
        let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
        
        let username: String? = userDefaults!.valueForKey("username") as! String?
        if let username = username {
            self.username.textLabel!.text = username
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
            bridge.detailTextLabel!.text = ""
        }
    }
    
    @IBAction func removeBridge() {
        let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
        userDefaults!.removeObjectForKey("hueIp")
        userDefaults!.removeObjectForKey("hueMac")
        userDefaults!.synchronize()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).phHueSDK.disableLocalConnection()
        
        self.refresh()
    }
}