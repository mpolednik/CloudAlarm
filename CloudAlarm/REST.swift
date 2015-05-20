//
//  REST.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

let BASE_URL = "http://cloud-alarm-server.herokuapp.com/api"

func register(username: String, password: String) -> Void {
    Alamofire.request(Method.POST, BASE_URL + "/users", parameters: ["username": username, "password": password], encoding: .JSON).responseJSON {
        (request, response, JSON, error) in
        let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
        
        if let json = JSON as? [String: String] {
            userDefaults!.setObject(username, forKey: "username")
            userDefaults!.setObject(json["access_token"]!, forKey: "accessToken")
            userDefaults!.synchronize()
        }
    }
}

func createAlarmForCurrentUser(alarm: Alarm) -> Void {
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    let accessToken: String? = userDefaults!.valueForKey("accessToken") as! String?
    
    // zformatujeme string z NSdate
    let formatter = NSDateFormatter()
    formatter.dateFormat = "Y-MM-d H:m:ss Z EEEEE"
    
    if let accessToken = accessToken {
        let url = BASE_URL + "/alarms?access_token=\(accessToken)"
        Alamofire.request(Method.POST, url, parameters: ["uuid": alarm.uuid, "title": alarm.label, "lastChanged": formatter.stringFromDate(alarm.last_changed), "enabled": alarm.enabled, "target": formatter.stringFromDate(alarm.target), "repeat": Array(alarm.repeat)], encoding: .JSON).responseJSON {
            (request, response, JSON, error) in
            // handle in production, leave now
        }
    }
}

func syncAlarms(controller: NSFetchedResultsController) -> Void {
    // v prvni rade stahneme available alarmy
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    let accessToken: String? = userDefaults!.valueForKey("accessToken") as! String?
    let knownAlarms = (controller.sections![0] as! NSFetchedResultsSectionInfo).objects
    var knownAlarmsDict: [String: Alarm] = [:]
    for alarm in knownAlarms {
        knownAlarmsDict[alarm.uuid] = alarm as? Alarm
    }
    
    if let accessToken = accessToken {
        Alamofire.request(Method.GET, BASE_URL + "/alarms", parameters: ["access_token": accessToken]).responseJSON {
            (request, response, JSON, error) in
            for alarm in JSON as! [String: AnyObject] {
                println(alarm)
                println("SEPARATOR")
            }
        }
    }
}