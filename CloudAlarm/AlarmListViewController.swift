//
//  ViewController.swift
//  CloudAlarm
//
//  Created by Martin Polednik on 4/17/15.
//  Copyright (c) 2015 cz.fi.muni. All rights reserved.
//

import UIKit
import CoreData

class AlarmListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AlarmTableViewCellDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBAction func unwindFromAddEdit(segue: UIStoryboardSegue) -> Void {
        let source: AlarmAddEditViewController = segue.sourceViewController as! AlarmAddEditViewController
        if let alarm = source.item {
            updateNotificationsForAlarm(alarm)
        }
        self.moc.save(nil)
        self.tableView.reloadData()
    }
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    let dateFormatter = NSDateFormatter()
    
    var _controller: NSFetchedResultsController? = nil
    var controller: NSFetchedResultsController {
        if self._controller == nil {
            let request: NSFetchRequest = NSFetchRequest(entityName: "Alarm")
            let sortingByEnabled: NSSortDescriptor = NSSortDescriptor(key: "enabled", ascending: false)
            let sortingByTarget: NSSortDescriptor = NSSortDescriptor(key: "target", ascending: true)
            request.sortDescriptors = [sortingByEnabled, sortingByTarget]
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
            controller.delegate = self
            controller.performFetch(nil)
            
            self._controller = controller
        }
        
        return self._controller!
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.moc.rollback()    }
    
    override func viewDidAppear(animated: Bool) {
        let userDefaults = NSUserDefaults(suiteName: "group.cz.muni.fi")
        
        let mail: String? = userDefaults!.valueForKey("mail") as! String?
        println(mail)
        if mail == nil {
            self.performSegueWithIdentifier("showIntro", sender: self)
        }
    }
    
    override func viewDidLoad() -> Void {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView?.hidden = true
        self.dateFormatter.setLocalizedDateFormatFromTemplate("H:m")
        initNotifications()
        
        // disable alarms, that were already triggered
        for alarm in (self.controller.sections![0] as! NSFetchedResultsSectionInfo).objects as! [Alarm] {
            if alarm.repeat.count == 0 && alarm.target.timeIntervalSinceNow <= 0 {
                alarm.enabled = false
            }
        }
        self.moc.save(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            let destination: UIViewController = segue.destinationViewController as! UIViewController
            
            switch identifier {
            case "showEdit":
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    (destination as! AlarmAddEditViewController).item = self.controller.objectAtIndexPath(indexPath) as? Alarm
                    (destination as! AlarmAddEditViewController).edit = true
                }
            case "showAdd":
                let newAlarm: Alarm = NSEntityDescription.insertNewObjectForEntityForName("Alarm", inManagedObjectContext: self.moc) as! Alarm
                newAlarm.initDefaults()
                
                (destination as! AlarmAddEditViewController).item = newAlarm
            default:
                break
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.controller.sections![section] as! NSFetchedResultsSectionInfo).numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AlarmTableViewCell = tableView.dequeueReusableCellWithIdentifier("AlarmTableViewCell") as! AlarmTableViewCell
        let alarm: Alarm = self.controller.objectAtIndexPath(indexPath) as! Alarm
        
        cell.setValues(alarm, delegate: self, dateFormatter: self.dateFormatter)

        return cell
    }
    
    func alarmStateChanged(cell: AlarmTableViewCell) {
        let alarm: Alarm = self.controller.objectAtIndexPath(self.tableView.indexPathForCell(cell)!) as! Alarm
        alarm.enabled = cell.uiSwitch.on
        updateNotificationsForAlarm(alarm)
        self.moc.save(nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let alarm: Alarm = self.controller.objectAtIndexPath(indexPath) as! Alarm
            deleteNotificationsForAlarm(alarm)
            self.moc.deleteObject(alarm)
            self.moc.save(nil)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Top)
        case .Update:
            if let indexPath = indexPath {
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? AlarmTableViewCell, alarm: Alarm = self.controller.objectAtIndexPath(indexPath) as? Alarm {

                    cell.setValues(alarm, delegate: self, dateFormatter: self.dateFormatter)
                }
            }
        case .Move:
            var rowAnimations = [UITableViewRowAnimation.Bottom, UITableViewRowAnimation.Top]
            if indexPath!.row > newIndexPath!.row {
                rowAnimations = rowAnimations.reverse()
            }
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: rowAnimations[0])
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: rowAnimations[1])
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Left)
        default:
            return
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}