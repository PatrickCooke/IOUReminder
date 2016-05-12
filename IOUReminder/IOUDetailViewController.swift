//
//  IOUDetailViewController.swift
//  IOUReminder
//
//  Created by Patrick Cooke on 5/12/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData

class IOUDetailViewController: UIViewController {

    var selectedIOU :IOUReminder?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var frequencySegBar: UISegmentedControl!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var paidSwitch: UISwitch!
    private var frequencyArray = ["Once", "Weekly on day", "Monthly on Day"]
    
    
    
    
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
