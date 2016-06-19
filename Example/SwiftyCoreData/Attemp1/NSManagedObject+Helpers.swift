//
//  NSManagedObject+Helpers.swift
//  SwiftyCoreData
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
  class func entityName() -> String {
    return NSStringFromClass(self)
      .componentsSeparatedByString(".").last!
  }

  class func object(managedObjectContext: NSManagedObjectContext,
                    predicate: NSPredicate?) -> NSManagedObject? {
    let fetchRequest = NSFetchRequest(entityName: entityName())
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? NSManagedObject
  }
}
