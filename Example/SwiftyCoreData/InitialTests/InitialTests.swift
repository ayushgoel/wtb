//
//  InitialTests.swift
//  InitialTests
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import XCTest
import CoreData
@testable import Initial

class InitialTests: XCTestCase {
  func testObjectSavedIsReturned() {
    let moc = testContext()
    let task1 = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: moc)
    guard let task = task1 as? Task else {
      assertionFailure()
      return
    }
    task.id = NSNumber(unsignedInt: arc4random())
    moc.saveContext()

    guard let retrievedTask = Task.object(moc, predicate: nil) else {
      assertionFailure()
      return
    }
    XCTAssertEqual(retrievedTask.id, task.id)
  }
}
