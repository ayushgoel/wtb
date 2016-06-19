
import Foundation
import CoreData

func testContext() -> NSManagedObjectContext {
  let context = NSManagedObjectContext(concurrency: .MainQueueConcurrencyType,
                                       directoryURL: NSURL(string: NSTemporaryDirectory())!,
                                       storeType: NSInMemoryStoreType)
  return context
}
