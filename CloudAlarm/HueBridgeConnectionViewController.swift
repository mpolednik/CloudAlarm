//
//  HueBridgeConnectionViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class HueBridgeConnectionController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    var selectedBridge: (String, String)? = nil
    
    override func viewDidLoad() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).phHueSDK.setBridgeToUseWithIpAddress(selectedBridge!.1, macAddress: selectedBridge!.0)
        
        let notificationManager = PHNotificationManager.defaultManager()
        notificationManager.registerObject(self, withSelector: "authenticationSuccess", forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
        notificationManager.registerObject(self, withSelector: "authenticationFailed", forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
        notificationManager.registerObject(self, withSelector: "noLocalConnection", forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
        notificationManager.registerObject(self, withSelector: "noLocalBridge", forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
        notificationManager.registerObject(self, withSelector: "buttonNotPressed:", forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
        (UIApplication.sharedApplication().delegate as! AppDelegate).phHueSDK.startPushlinkAuthentication()
    }
    
    /// Notification receiver which is called when the pushlinking was successful
    func authenticationSuccess() {
        // The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION was received. We have confirmed the bridge.
        
        // De-register for notifications and call pushLinkSuccess on the delegate
        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
        
        let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
        
        userDefaults!.setObject(selectedBridge!.0, forKey: "hueMac")
        userDefaults!.setObject(selectedBridge!.1, forKey: "hueIp")
        userDefaults!.synchronize()
        
        self.performSegueWithIdentifier("bridgeSetupFinished", sender: self)
    }
    
    /// Notification receiver which is called when the pushlinking failed because the time limit was reached
    func authenticationFailed() {
        // De-register for notifications and call pushLinkSuccess on the delegate
        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
        
        let error = PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_TIME_LIMIT_REACHED.value), userInfo: [NSLocalizedDescriptionKey: "Authentication failed: time limit reached."])
        
        println(error)
    }
    
    /// Notification receiver which is called when the pushlinking failed because the local connection to the bridge was lost
    func noLocalConnection() {
        // Deregister for all notifications
        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
        
        let error = PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_NO_CONNECTION.value), userInfo: [NSLocalizedDescriptionKey: "Authentication failed: No local connection to bridge."])
        
        println(error)
    }
    
    /// Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
    func noLocalBridge() {
        // Deregister for all notifications
        PHNotificationManager.defaultManager().deregisterObjectForAllNotifications(self)
        
        let error = PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_NO_LOCAL_BRIDGE.value), userInfo: [NSLocalizedDescriptionKey: "Authentication failed: No local bridge found."])
        
        println(error)
    }
    
    /// This method is called when the pushlinking is still ongoing but no button was pressed yet.
    /// :param: notification The notification which contains the pushlinking percentage which has passed.
    func buttonNotPressed(notification: NSNotification) {
        // Update status bar with percentage from notification
        let dict = notification.userInfo!
        let progressPercentage = dict["progressPercentage"] as! Int!
        
        // Convert percentage to the progressbar scale
        let progressBarValue = Float(progressPercentage) / 100.0
        progressView.progress = progressBarValue
    }
}
