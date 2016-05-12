//
//  ViewController.swift
//  IOUReminder
//
//  Created by Patrick Cooke on 5/12/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData
import EventKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    let eventStore = EKEventStore()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var iouArray = [IOUReminder]()
    @IBOutlet private weak var iouTableView: UITableView!
    var sortmode = Bool()

    
    //MARK: - Interactivity Methods
    
    @IBAction func sortTable(sender: UIBarButtonItem) {
        if sortmode {
            sortmode = false
            self.refreshTableData()
        } else {
            sortmode = true
            self.refreshTableData()
        }
    }
    
    
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destController = segue.destinationViewController as! IOUDetailViewController
        if segue.identifier == "seeSelectedIOU" {
            let indexPath = iouTableView.indexPathForSelectedRow!
            let selectedIOU = iouArray[indexPath.row]
            destController.selectedIOU = selectedIOU
            iouTableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if segue.identifier == "addNewIOU" {
            destController.selectedIOU = nil
        }
        
    }

    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iouArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let currentIOU = iouArray[indexPath.row]
        cell.textLabel!.text = currentIOU.iouTitle
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm EEEE, MMM d, yyyy"
        let timestring = formatter.stringFromDate(currentIOU.iouDate!)
        cell.detailTextLabel!.text = timestring
        return cell
    }
    
    //MARK: - Fetch Data Method
    
    func fetchEntries() -> [IOUReminder]? {
        let fetchRequest = NSFetchRequest(entityName: "IOUReminder")
        if sortmode == true {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "iouTitle", ascending: true)]
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "iouDate", ascending: true)]
        }
        do {
            let tempArray = try managedObjectContext.executeFetchRequest(fetchRequest) as! [IOUReminder]
            return tempArray
        }catch {
            return nil
        }
    }
    
    func refreshTableData() {
        self.fetchEntries()
        iouTableView.reloadData()
    }
    
    //MARK: - TempAdd Core Data
    
    func tempAddRecords() {
        let entityDescription = NSEntityDescription.entityForName("IOUReminder", inManagedObjectContext: managedObjectContext)!
        
        let newIOU1 = IOUReminder(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        newIOU1.iouTitle = "Dave's Lunch Money"
        newIOU1.iouDate = NSDate()
        newIOU1.iouFrequency = 0
        newIOU1.iouTimeInAdvance = NSDate()
        newIOU1.iouPaidStatus = false
        newIOU1.iouIdentifier = ""
        
        let newIOU2 = IOUReminder(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        newIOU2.iouTitle = "TIY loan payment"
        newIOU2.iouDate = NSDate()
        newIOU2.iouFrequency = 2
        newIOU2.iouTimeInAdvance = NSDate()
        newIOU2.iouPaidStatus = false
        newIOU2.iouIdentifier = ""
        
        appDelegate.saveContext()
    }
    
    //MARK: - Permission Methods
    
    private func requestAccessToEKType(type: EKEntityType) {
        eventStore.requestAccessToEntityType(type) { (accessGranted, error) -> Void in
            if accessGranted {
                print("Granted for \(type.rawValue)")
            } else {
                print("Not Granted for \(type.rawValue)")
            }
        }
    }
    
    private func checkEKAuthorizationStatus(type: EKEntityType) {
        let status = EKEventStore.authorizationStatusForEntityType(type)
        switch status {
        case .NotDetermined:
            print("Not Determined")
            requestAccessToEKType(type)
        case .Authorized:
            print("authorized")
        case .Restricted, .Denied:
            print("Restricted/Denied")
        }
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkEKAuthorizationStatus(.Event)
        checkEKAuthorizationStatus(.Reminder)
        //tempAddRecords()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        iouArray = fetchEntries()!
        print(iouArray.count)
        self.refreshTableData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

