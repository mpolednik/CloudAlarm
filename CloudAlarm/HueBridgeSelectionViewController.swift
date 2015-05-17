//
//  HueBridgeSelectionViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 5/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit

class HueBridgeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var keys: [String] = []
    var bridges: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bridgeSearch = PHBridgeSearching(upnpSearch: true, andPortalSearch: true, andIpAdressSearch: false)
        bridgeSearch.startSearchWithCompletionHandler {
            (bridgesFound: [NSObject: AnyObject]!) -> () in
            self.bridges = bridgesFound as! [String: String]
            self.keys = [String](self.bridges.keys)
            self.tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BridgeCell") as! UITableViewCell
        cell.textLabel!.text = self.bridges[self.keys[indexPath.row]]
        cell.detailTextLabel!.text = self.keys[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "startPushlink" {
            let destination: HueBridgeConnectionController = segue.destinationViewController as! HueBridgeConnectionController
            let row = self.tableView.indexPathForSelectedRow()!.row
            destination.selectedBridge = (self.keys[row], self.bridges[self.keys[row]]!)
        }
    }
}