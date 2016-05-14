//
//  IOUReminder+CoreDataProperties.swift
//  IOUReminder
//
//  Created by Patrick Cooke on 5/14/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension IOUReminder {

    @NSManaged var iouDate: NSDate?
    @NSManaged var iouFrequency: NSNumber?
    @NSManaged var iouIdentifier: String?
    @NSManaged var iouPaidStatus: NSNumber?
    @NSManaged var iouTimeInAdvance: NSDate?
    @NSManaged var iouTitle: String?

}
