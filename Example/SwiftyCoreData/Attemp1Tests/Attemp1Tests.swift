//
//  Attemp1Tests.swift
//  Attemp1Tests
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import XCTest
import CoreData
@testable import Attemp1

class Attemp1Tests: XCTestCase {
  func testEntityName() {
    XCTAssertEqual("Task", Task.entityName())
  }

  func testObjectSavedIsReturned() {
    let moc = testContext()
    guard let task = NSEntityDescription.insertNewObjectForEntityForName(Task.entityName(), inManagedObjectContext: moc) as? Task else {
      assertionFailure()
      return
    }
    task.id = NSNumber(unsignedInt: arc4random())
    moc.saveContext()

    guard let retrievedTask = Task.object(moc, predicate: nil) as? Task else {
      assertionFailure()
      return
    }
    XCTAssertEqual(retrievedTask.id, task.id)
  }

}
