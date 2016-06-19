
import Foundation
import CoreData

private func applicationDocumentsDirectory() -> NSURL {
  // The directory the application uses to store the Core Data store file. This code uses a directory named "com.techmyway.Checkvistle" in the application's documents Application Support directory.
  let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
  return urls[urls.count - 1]
}

private func managedObjectModel() -> NSManagedObjectModel {
  // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
  let modelURL = NSBundle.mainBundle().URLForResource("SwiftyCoreData", withExtension: "momd")!
  return NSManagedObjectModel(contentsOfURL: modelURL)!
}

private func persistentStoreCoordinator(directoryURL:NSURL, storeType: String) -> NSPersistentStoreCoordinator {
  // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
  // Create the coordinator and store
  let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel())
  let url = directoryURL.URLByAppendingPathComponent("coredata.sqlite")
  do {
    try coordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: url, options: nil)
  } catch {
    // Report any error we got.
    let dict = [
      NSLocalizedDescriptionKey: "Failed to initialize the application's saved data",
      NSLocalizedFailureReasonErrorKey: "There was an error creating or loading the application's saved data.",
      NSUnderlyingErrorKey: error as NSError
    ]
    let encapsulatedError = NSError(domain: "SwiftyCoreDataErrorDomain", code: 9999, userInfo: dict as [NSObject : AnyObject])
    // Replace this with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    print("Unresolved error \(encapsulatedError), \(encapsulatedError.userInfo)")
    abort()
  }
  return coordinator
}

private class PersistentStoreCoordinator {
  static var coordinator: NSPersistentStoreCoordinator?

  static func coordinator(directoryURL:NSURL, storeType: String) {
    coordinator = persistentStoreCoordinator(directoryURL, storeType: storeType)
  }
}

extension NSManagedObjectContext {
  convenience init(concurrency: NSManagedObjectContextConcurrencyType, directoryURL: NSURL, storeType: String) {
    if PersistentStoreCoordinator.coordinator == nil {
      PersistentStoreCoordinator.coordinator(directoryURL, storeType: storeType)
    }
    self.init(concurrencyType: concurrency)
    persistentStoreCoordinator = PersistentStoreCoordinator.coordinator
  }

  convenience init(concurrency: NSManagedObjectContextConcurrencyType) {
    self.init(concurrency: concurrency, directoryURL: applicationDocumentsDirectory(), storeType: NSSQLiteStoreType)
  }
}
