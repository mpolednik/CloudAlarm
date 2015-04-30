//
//  Alarm.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 4/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import Foundation
import CoreData

class Alarm: NSManagedObject {

    @NSManaged var uuid: String
    @NSManaged var enabled: Bool
    @NSManaged var target: NSDate
    @NSManaged var label: String
    @NSManaged var repeat: [Int]

    func initDefaults() {
        self.enabled = true
        self.uuid = NSUUID().UUIDString
        self.repeat = []
        self.target = NSDate()
        self.label = ""
    }
}
