//
//  utils.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import Foundation

func shortUUID(uuid: String) -> String {
    return uuid.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil)
}

func dateComponentsFromCalendarForDate(calendar: NSCalendar, from: NSDate) -> NSDateComponents {
    return calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitWeekday, fromDate: from)
}