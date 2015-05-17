//
//  utils.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import Foundation

func hueIntegrationEnabled() -> Bool {
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")

    let hueIp: String? = userDefaults!.valueForKey("hueIp") as! String?
    let hueMac: String? = userDefaults!.valueForKey("hueMac") as! String?

    if let ip = hueIp, mac = hueMac {
        return true
    }
    
    return false
}

func shortUUID(uuid: String) -> String {
    return uuid.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil)
}