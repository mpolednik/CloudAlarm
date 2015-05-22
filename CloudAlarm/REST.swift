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
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    userDefaults!.setObject(username, forKey: "username")
    
    Alamofire.request(Method.POST, BASE_URL + "/users", parameters: ["username": username, "password": password], encoding: .JSON).response {
        (request, response, data, error) in
        let json = JSON(data: (data as? NSData)!)
        if let accessToken = json["access_token"].string {
            userDefaults!.setObject(accessToken, forKey: "accessToken")
        } else {
            Alamofire.request(Method.GET, BASE_URL + "/user").authenticate(user: username, password: password).response {
                (request, response, data, error) in
                let json = JSON(data: (data as? NSData)!)
                userDefaults!.setObject(json["token"].string, forKey: "accessToken")
                userDefaults!.synchronize()
            }
        }
    }
}

func createRESTAlarmForCurrentUser(alarm: Alarm) -> Void {
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    let accessToken: String? = userDefaults!.valueForKey("accessToken") as! String?
    
    // zformatujeme string z NSdate
    let formatter = NSDateFormatter()
    formatter.dateFormat = "Y-MM-d H:m:ss Z EEEEE"
    
    if let accessToken = accessToken {
        let url = BASE_URL + "/alarms?access_token=\(accessToken)"
        if let lastChanged = alarm.last_changed {
            Alamofire.request(Method.POST, url, parameters: ["uuid": alarm.uuid, "title": alarm.label, "lastChanged": formatter.stringFromDate(lastChanged), "enabled": alarm.enabled, "target": formatter.stringFromDate(alarm.target), "repeat": Array(alarm.repeat)], encoding: .JSON).responseJSON {
                (request, response, JSON, error) in
                // handle in production, leave now
            }
        }
    }
}

func updateRESTAlarmForCurrentUser(alarm: Alarm) -> Void {
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    let accessToken: String? = userDefaults!.valueForKey("accessToken") as! String?
    
    // zformatujeme string z NSdate
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd H:mm:ss Z EEEEE"
    
    if let accessToken = accessToken {
        var url = BASE_URL + "/alarms/\(alarm.uuid)"
        Alamofire.request(Method.GET, url, parameters: ["access_token": accessToken]).response {
            (request, response, data, error) in
            let json = JSON(data: (data as? NSData)!)
            if json["data"] != JSON.nullJSON {
                if formatter.dateFromString(json["data"]["lastChanged"].string!)!.timeIntervalSinceDate(alarm.last_changed!) > 0 {
                    alarm.last_changed = formatter.dateFromString(json["data"]["lastChanged"].string!)!
                    alarm.target = formatter.dateFromString(json["data"]["target"].string!)!
                    if let removed = json["data"]["removed"].bool {
                        alarm.removed = removed
                    } else {
                        alarm.removed = false
                    }
                    alarm.enabled = json["data"]["enabled"].bool!
                    alarm.label = json["data"]["title"].string!
                } else {
                    url = BASE_URL + "/alarms/\(alarm.uuid)?access_token=\(accessToken)"
                    Alamofire.request(Method.PUT, url, parameters: ["uuid": alarm.uuid, "title": alarm.label, "lastChanged": formatter.stringFromDate(alarm.last_changed!), "enabled": alarm.enabled, "target": formatter.stringFromDate(alarm.target), "repeat": Array(alarm.repeat)], encoding: .JSON).responseJSON {
                        (request, response, JSON, error) in
                        // handle in production, leave now
                    }
                }
            } else {
                createRESTAlarmForCurrentUser(alarm)
            }
        }
    }
}

func deleteRESTAlarmForCurrentUser(alarm: Alarm) {
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    let accessToken: String? = userDefaults!.valueForKey("accessToken") as! String?
    
    // zformatujeme string z NSdate
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd H:mm:ss Z EEEEE"
    
    if let accessToken = accessToken {
        var url = BASE_URL + "/alarms/\(alarm.uuid)"
        Alamofire.request(Method.DELETE, url, parameters: ["access_token": accessToken]).response {
            (request, response, data, error) in
        }
    }
}

func syncAlarms(controller: NSFetchedResultsController, moc: NSManagedObjectContext) -> Void {
    let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    let accessToken: String? = userDefaults!.valueForKey("accessToken") as! String?
    let knownAlarms = (controller.sections![0] as! NSFetchedResultsSectionInfo).objects
    var knownAlarmsDict: [String: Alarm] = [:]
    for alarm in knownAlarms {
        knownAlarmsDict[alarm.uuid] = alarm as? Alarm
    }
    
    // zformatujeme string z NSdate
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd H:mm:ss Z EEEEE"
    
    if let accessToken = accessToken {
        Alamofire.request(Method.GET, BASE_URL + "/alarms", parameters: ["access_token": accessToken]).response {
            (request, response, data, error) in
            let json = JSON(data: (data as? NSData)!)
            for alarm in json["data"] {
                if let knownAlarm = knownAlarmsDict.indexForKey(alarm.1["uuid"].string!) {
                    updateRESTAlarmForCurrentUser(knownAlarmsDict[alarm.1["uuid"].string!]!)
                } else {
                    let newAlarm: Alarm = NSEntityDescription.insertNewObjectForEntityForName("Alarm", inManagedObjectContext: moc) as! Alarm
                    newAlarm.last_changed = formatter.dateFromString(alarm.1["lastChanged"].string!)!
                    newAlarm.target = formatter.dateFromString(alarm.1["target"].string!)!
                    if let removed = alarm.1["removed"].bool {
                        newAlarm.removed = removed
                    } else {
                        newAlarm.removed = false
                    }
                    newAlarm.enabled = alarm.1["enabled"].bool!
                    newAlarm.label = alarm.1["title"].string!
                    newAlarm.uuid = alarm.1["uuid"].string!
                    updateNotificationsForAlarm(newAlarm)
                }
            }
            
            for alarm in knownAlarms {
                updateRESTAlarmForCurrentUser(alarm as! Alarm)
            }
        }
    }
}