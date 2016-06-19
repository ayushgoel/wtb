//
//  NSManagedObjectContext+Helpers.swift
//  SwiftyCoreData
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
  func saveContext() {
    if hasChanges {
      do {
        try save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        print("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
}
