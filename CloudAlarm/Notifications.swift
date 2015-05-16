//
//  Notifications.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/2/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit
import CoreData


func initNotifications() {
    let category = UIMutableUserNotificationCategory()
    category.identifier = "ALARM_FIRED"
    
    let actionSnooze = UIMutableUserNotificationAction()
    actionSnooze.identifier = "SNOOZE"
    actionSnooze.title = "Snooze"
    actionSnooze.activationMode = UIUserNotificationActivationMode.Background
    actionSnooze.authenticationRequired = false
    actionSnooze.destructive = false
    
    let actionDissmiss = UIMutableUserNotificationAction()
    actionDissmiss.identifier = "DISMISS"
    actionDissmiss.title = "Dismiss"
    actionDissmiss.activationMode = UIUserNotificationActivationMode.Background
    actionDissmiss.authenticationRequired = false
    actionDissmiss.destructive = false
    
    category.setActions([actionSnooze, actionDissmiss], forContext: UIUserNotificationActionContext.Default)
    let categories: Set<UIUserNotificationCategory> = [category]
    let types: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
    let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: categories)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
}

func findNotificationsForAlarm(alarm: Alarm) -> [UILocalNotification] {
    var notifications: [UILocalNotification] = []
    
    for item in UIApplication.sharedApplication().scheduledLocalNotifications {
        if let notification = item as? UILocalNotification, userInfo = notification.userInfo, uuid: String = userInfo["uuid"] as? String where uuid == alarm.uuid {
            notifications.append(notification)
        }
    }
    
    return notifications
}

func createSnoozeForNotification(notification: UILocalNotification) {
    let reminder = UILocalNotification()
    let calendar: NSCalendar = NSCalendar.currentCalendar()
    
    let minuteDifference: NSDateComponents = NSDateComponents()
    minuteDifference.minute = 5
    
    reminder.fireDate = calendar.dateByAddingComponents(minuteDifference, toDate: NSDate(), options: nil)
    reminder.category = "ALARM_FIRED"
    reminder.alertTitle = notification.alertBody
    reminder.alertBody = "TEST"
    reminder.userInfo = ["uuid": notification.userInfo!["uuid"]!]
    reminder.soundName = "alarm.caf"
    
    UIApplication.sharedApplication().scheduleLocalNotification(reminder)
    return
}

func addAlarmTargetToSharedDefaults(alarm: Alarm) {
    let sharedDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
    var copy = sharedDefaults!.valueForKey("fireDates")!.mutableCopy() as! [String: [NSDate]]
    copy[alarm.uuid] = [alarm.target]
    sharedDefaults!.setObject(copy, forKey: "fireDates")
    sharedDefaults!.synchronize()
}

func createNotificationsForAlarm(alarm: Alarm) {
    if !alarm.enabled {
        return
    }
    
    if alarm.repeat.count == 0 || alarm.repeat.count == 7 {
        let notification = UILocalNotification()
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let dateComponents: NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitWeekday, fromDate: alarm.target)
        let todayDateComponents: NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitWeekday, fromDate: NSDate())
        
        todayDateComponents.second = 0
        
        var target: NSDate? = nil
        if dateComponents.hour < todayDateComponents.hour || (dateComponents.hour == todayDateComponents.hour && dateComponents.minute <= todayDateComponents.minute) {
            todayDateComponents.hour = dateComponents.hour
            todayDateComponents.minute = dateComponents.minute
            target = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: calendar.dateFromComponents(todayDateComponents)!, options: NSCalendarOptions(0))
            println(target!.timeIntervalSinceNow)
        } else {
            todayDateComponents.hour = dateComponents.hour
            todayDateComponents.minute = dateComponents.minute
            target = calendar.dateFromComponents(todayDateComponents)
        }
        alarm.target = target!
        
        notification.fireDate = target
        notification.category = "ALARM_FIRED"
        notification.alertTitle = alarm.label
        notification.alertBody = "Good morning!"
        notification.userInfo = ["uuid": alarm.uuid]
        notification.soundName = "alarm.caf"
        if alarm.repeat.count == 7 {
            notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
        }
        
        addAlarmTargetToSharedDefaults(alarm)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return
    }
    
    for day in alarm.repeat {
        let notification = UILocalNotification()
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let dateComponents: NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitWeekday, fromDate: alarm.target)
        
        dateComponents.second = 0
        
        let target: NSDate = calendar.dateFromComponents(dateComponents)!
        
        let dayDifference: NSDateComponents = NSDateComponents()
        dayDifference.day = (day - dateComponents.weekday + 1) % 8

        notification.fireDate = calendar.dateByAddingComponents(dayDifference, toDate: target, options: nil)
        notification.category = "ALARM_FIRED"
        notification.alertTitle = alarm.label
        notification.alertBody = "TEST"
        notification.userInfo = ["uuid": alarm.uuid]
        notification.repeatInterval = NSCalendarUnit.CalendarUnitWeekday
        notification.soundName = "alarm.caf"
        
        addAlarmTargetToSharedDefaults(alarm)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return
    }
}

func deleteNotificationsForAlarm(alarm: Alarm) {
    for notification in findNotificationsForAlarm(alarm) {
        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
}

func updateNotificationsForAlarm(alarm: Alarm) {
    deleteNotificationsForAlarm(alarm)
    createNotificationsForAlarm(alarm)
}