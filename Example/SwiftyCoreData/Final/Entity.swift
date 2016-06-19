//
//  Entity.swift
//  SwiftyCoreData
//
//  Created by Ayush Goel on 19/06/16.
//  Copyright © 2016 Ayush Goel. All rights reserved.
//

import Foundation

protocol Entity {
  associatedtype Context
  static func name() -> String
  static func object(context: Context,
                     predicate: NSPredicate?) -> Self?
}
