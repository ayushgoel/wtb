//
//  Task+CoreDataProperties.swift
//  SwiftyCoreData
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Task {

    @NSManaged var id: NSDecimalNumber?
    @NSManaged var text: String?

}
