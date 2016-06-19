//
//  FinalTests.swift
//  FinalTests
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import XCTest
import CoreData
@testable import Final

class FinalTests: XCTestCase {
  func testEntityName() {
    XCTAssertEqual("Task", Task.name())
  }

  func testObjectSavedIsReturned() {
    let moc = testContext()
    guard let task = NSEntityDescription.insertNewObjectForEntityForName(Task.name(), inManagedObjectContext: moc) as? Task else {
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
