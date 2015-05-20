//
//  Alarm.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/20/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import Foundation
import CoreData

class Alarm: NSManagedObject {

    @NSManaged var enabled: Bool
    @NSManaged var label: String
    @NSManaged var repeat: Set<Int>
    @NSManaged var target: NSDate
    @NSManaged var uuid: String
    @NSManaged var removed: Bool
    @NSManaged var last_changed: NSDate

    func initDefaults() {
        self.enabled = true
        self.uuid = NSUUID().UUIDString
        self.repeat = []
        self.target = NSDate()
        self.label = ""
        self.removed = false
    }
}