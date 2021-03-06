//
//  IOUDetailViewController.swift
//  IOUReminder
//
//  Created by Patrick Cooke on 5/12/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class IOUDetailViewController: UIViewController {

    let eventStore = EKEventStore()
    var selectedIOU :IOUReminder?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var frequencySegBar: UISegmentedControl!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var paidSwitch: UISwitch!
    private var frequencyArray = ["Once", "Weekly on day", "Monthly on Day"]

    
    //MARK: - Reoccuring Reminder Methods
    
    private func newReminder(minutes:Double) {
        let entityDescription = NSEntityDescription.entityForName("IOUReminder", inManagedObjectContext: managedObjectContext)!
        selectedIOU = IOUReminder(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        selectedIOU!.iouTitle = titleTextfield.text
        selectedIOU!.iouDate = dueDatePicker.date.dateByAddingTimeInterval(minutes)
        selectedIOU!.iouFrequency = frequencySegBar.selectedSegmentIndex
        selectedIOU!.iouTimeInAdvance = reminderDatePicker.date.dateByAddingTimeInterval(minutes)
        selectedIOU!.iouPaidStatus = false
        
        addCalAndRem(minutes)
    }
    
    private func addCalAndRem(minutes:Double){
        let reminder = EKReminder(eventStore: eventStore)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        if let remindTitle = titleTextfield.text {
            reminder.title = remindTitle
            let alarm = EKAlarm(absoluteDate: reminderDatePicker.date.dateByAddingTimeInterval(minutes))
            reminder.addAlarm(alarm)
            do {
                try eventStore.saveReminder(reminder, commit: true)
            } catch {
                print("Got Error")
            }
        }
        let calEvent = EKEvent(eventStore: eventStore)
        calEvent.calendar = eventStore.defaultCalendarForNewEvents
        calEvent.title = titleTextfield.text!
        calEvent.startDate = dueDatePicker.date.dateByAddingTimeInterval(minutes)
        calEvent.endDate = (dueDatePicker.date.dateByAddingTimeInterval(minutes + 3600))
        do {
            try eventStore.saveEvent(calEvent, span: .ThisEvent, commit: true)
        } catch {
            print("Got Error")
        }

    }
    
    private func createNewReminder() {
        if paidSwitch.on {
            switch frequencySegBar.selectedSegmentIndex {
            case 0:
                print("reminder finished")
            case 1:
                print("add a reminder in 1 week")
                newReminder(Double(60 * 60 * 24 * 7))
            case 2:
                print("add a reminder in 1 month")
                newReminder(Double(60 * 60 * 24 * 30))
            default:
                print("Never Should Happen")
            }
        } else {
            print("not finished")
            // saving reminder
            addCalAndRem(0)

        }
        
    }
    
    //MARK: - Interactivity Methods
    
    func saveAndPop() {
        appDelegate.saveContext()
        self.navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func saveButton(sender: UIBarButtonItem) {
        selectedIOU!.iouTitle = titleTextfield.text
        selectedIOU!.iouDate = dueDatePicker.date
        selectedIOU!.iouFrequency = frequencySegBar.selectedSegmentIndex
        selectedIOU!.iouTimeInAdvance = reminderDatePicker.date
        if paidSwitch.on {
            selectedIOU!.iouPaidStatus = true
        } else {
            selectedIOU!.iouPaidStatus = false
        }
        createNewReminder()
        self.saveAndPop()
    }
    
    @IBAction func deletebutton(sender: UIBarButtonItem) {
        if let selContact = selectedIOU{
            managedObjectContext.deleteObject(selContact)
            self.saveAndPop()
        }
    }

    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedIOU == nil {
            let entityDescription = NSEntityDescription.entityForName("IOUReminder", inManagedObjectContext: managedObjectContext)!
            selectedIOU = IOUReminder(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
            
            titleTextfield.text = ""
            dueDatePicker.date = NSDate()
            frequencySegBar.selectedSegmentIndex = 0
            reminderDatePicker.date = NSDate()
            paidSwitch.on = false
        } else {
            titleTextfield.text = selectedIOU!.iouTitle
            dueDatePicker.date = (selectedIOU!.iouDate!)
            frequencySegBar.selectedSegmentIndex = (selectedIOU?.iouFrequency?.integerValue)!
            reminderDatePicker.date = (selectedIOU!.iouTimeInAdvance!)
            paidSwitch.on = (selectedIOU!.iouPaidStatus?.boolValue)!
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (managedObjectContext .hasChanges) {
            managedObjectContext .rollback()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
