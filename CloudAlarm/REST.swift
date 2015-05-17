//
//  REST.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL = "http://cloud-alarm-server.herokuapp.com/api"

func register(username: String, password: String) {
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
