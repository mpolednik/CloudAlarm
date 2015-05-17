//
//  Notifications.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/2/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit
import CoreData


func notificationForAlarm(alarm: Alarm) -> UILocalNotification {
    let notification: UILocalNotification = UILocalNotification()
    
    notification.fireDate = alarm.target
    notification.category = "ALARM_FIRED"
    notification.alertTitle = alarm.label
    notification.alertBody = "Good morning!"
    notification.userInfo = ["uuid": alarm.uuid]
    notification.soundName = "alarm.caf"
    
    return notification
}

func notificationForSnooze(notification: UILocalNotification) -> UILocalNotification {
    let snoozeNotification: UILocalNotification = UILocalNotification()
    
    snoozeNotification.category = "ALARM_FIRED"
    snoozeNotification.alertTitle = notification.alertBody
    snoozeNotification.alertBody = "Good morning!"
    snoozeNotification.userInfo = ["uuid": notification.userInfo!["uuid"]!]
    snoozeNotification.soundName = "alarm.caf"
    
    return snoozeNotification
}


func initNotifications() {
    let category = UIMutableUserNotificationCategory()
    category.identifier = "ALARM_FIRED"
    var actions: [UIMutableUserNotificationAction] = []
    
    for actionString in ["Snooze", "Dissmiss"] {
        let action = UIMutableUserNotificationAction()
        action.identifier = actionString.uppercaseString
        action.title = actionString
        action.activationMode = UIUserNotificationActivationMode.Background
        action.authenticationRequired = false
        action.destructive = false
        
        actions.append(action)
    }
    
    category.setActions(actions, forContext: UIUserNotificationActionContext.Default)
    UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound, categories: [category]))
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
    let calendar: NSCalendar = NSCalendar.currentCalendar()
    
    let minuteDifference: NSDateComponents = NSDateComponents()
    minuteDifference.minute = 5
    
    let reminder = notificationForSnooze(notification)
    reminder.fireDate = calendar.dateByAddingComponents(minuteDifference, toDate: NSDate(), options: nil)
    hueScheduleForSnooze(calendar, minuteDifference)
    
    UIApplication.sharedApplication().scheduleLocalNotification(reminder)
}

func createNotificationsForAlarm(alarm: Alarm) {
    if !alarm.enabled {
        return
    }
    
    let calendar: NSCalendar = NSCalendar.currentCalendar()
    let dateComponents: NSDateComponents = dateComponentsFromCalendarForDate(calendar, alarm.target)
    dateComponents.second = 0
    
    if alarm.repeat.count == 0 || alarm.repeat.count == 7 {
        let todayDateComponents: NSDateComponents = dateComponentsFromCalendarForDate(calendar, NSDate())
        todayDateComponents.second = 0
        let pastTodayDateComponents: NSDateComponents = todayDateComponents.copy() as! NSDateComponents
        todayDateComponents.hour = dateComponents.hour
        todayDateComponents.minute = dateComponents.minute
        
        var target: NSDate? = nil
        if dateComponents.hour < pastTodayDateComponents.hour || (dateComponents.hour == pastTodayDateComponents.hour && dateComponents.minute <= pastTodayDateComponents.minute) {
            target = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: calendar.dateFromComponents(todayDateComponents)!, options: NSCalendarOptions(0))
        } else {
            target = calendar.dateFromComponents(todayDateComponents)
        }
        alarm.target = target!
        
        let notification: UILocalNotification = notificationForAlarm(alarm)
        if alarm.repeat.count == 7 {
            notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
        }
        
        hueScheduleForAlarm(alarm)
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return
    }
    
    for day in alarm.repeat {
        let target: NSDate = calendar.dateFromComponents(dateComponents)!
        
        let dayDifference: NSDateComponents = NSDateComponents()
        dayDifference.day = (day - dateComponents.weekday + 1) % 8

        alarm.target = calendar.dateByAddingComponents(dayDifference, toDate: target, options: nil)!
        
        let notification: UILocalNotification = notificationForAlarm(alarm)
        notification.repeatInterval = NSCalendarUnit.CalendarUnitWeekday
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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