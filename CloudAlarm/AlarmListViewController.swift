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
        self.moc.rollback()
    }
    
    override func viewDidLoad() -> Void {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dateFormatter.setLocalizedDateFormatFromTemplate("H:m")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            let destination: AlarmAddEditViewController = segue.destinationViewController as! AlarmAddEditViewController
            
            switch identifier {
            case "showEdit":
                if let indexPath = self.tableView.indexPathForSelectedRow() {
                    destination.item = self.controller.objectAtIndexPath(indexPath) as? Alarm
                    destination.edit = true
                }
            case "showAdd":
                let newAlarm: Alarm = NSEntityDescription.insertNewObjectForEntityForName("Alarm", inManagedObjectContext: self.moc) as! Alarm
                newAlarm.initDefaults()
                
                destination.item = newAlarm
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
        (self.controller.objectAtIndexPath(self.tableView.indexPathForCell(cell)!) as! Alarm).enabled = cell.uiSwitch.on
        self.moc.save(nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let alarm: Alarm = self.controller.objectAtIndexPath(indexPath) as! Alarm
            self.moc.deleteObject(alarm)
            self.moc.save(nil)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! AlarmTableViewCell
            let alarm: Alarm = self.controller.objectAtIndexPath(indexPath!) as! Alarm
            cell.setValues(alarm, delegate: self, dateFormatter: self.dateFormatter)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
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