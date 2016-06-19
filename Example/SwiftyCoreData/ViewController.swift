//
//  ViewController.swift
//  Attemp1
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  override func viewDidLoad() {
    let context = testContext()
    context.saveContext()
  }
}
