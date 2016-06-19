//
//  Entity+Extensions.swift
//  SwiftyCoreData
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import Foundation
import CoreData

extension Entity where Self: NSManagedObject {
  static func name() -> String {
    return NSStringFromClass(self)
      .componentsSeparatedByString(".").last!
  }
}

extension Entity where Context == NSManagedObjectContext {
  static func object(context: Context, predicate: NSPredicate?) -> Self? {
    let req = NSFetchRequest(entityName: name())
    req.predicate = predicate
    guard let result = try? context.executeFetchRequest(req) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? Self
  }
}
