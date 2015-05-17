//
//  Hue.swift
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

func hueBasicSchedule(state: PHLightState) -> PHSchedule {
    let schedule = PHSchedule()
    
    schedule.groupIdentifier = "0"
    schedule.state = state
    
    return schedule
}

func hueBasicState() -> PHLightState {
    let state = PHLightState()
    
    state.brightness = 254
    state.transitionTime = 150
    state.on = true
    
    return state
}

func hueScheduleForAlarm(alarm: Alarm) {
    if !hueIntegrationEnabled() {
        return
    }
    
    let schedule = hueBasicSchedule(hueBasicState())
    schedule.name = shortUUID(alarm.uuid)
    schedule.date = alarm.target

    let request = PHBridgeSendAPI()
    request.createSchedule(schedule) {
        (errors) -> Void in
        println(errors)
    }
}

func hueScheduleForSnooze(calendar: NSCalendar, timeDiff: NSDateComponents) {
    if !hueIntegrationEnabled() {
        return
    }
    
    let request = PHBridgeSendAPI()
    let state = PHLightState()
    state.on = false
    state.brightness = 0
    request.setLightStateForGroupWithId("0", lightState: state) {
        (errors) -> Void in
        println(errors)
    }
    
    let schedule = hueBasicSchedule(hueBasicState())
    schedule.date = calendar.dateByAddingComponents(timeDiff, toDate: NSDate(), options: nil)
    
    request.createSchedule(schedule) {
        (errors) -> Void in
        println(errors)
    }
}