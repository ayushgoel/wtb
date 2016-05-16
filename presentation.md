class: center, middle

# Swifty Core Data

Making things a bit more bearable

.footnote[.red.bold[*] Important footnote]

???

Title slide

---

name: Agenda

# Agenda

1. Core data stack
2. NSManagedObject extensions: Protocol extensions to the rescue
3. Moc synchronizer
4. Protocol tests makes it easier to test these NSManagedObject's functionalities
5. Model mirrored in NSManagedObject's definition
6. Swift 3's impact on these ideas

???

The agenda to be followed in the presentation
---

`NSManagedObject`

```
class Task: NSManagedObject {

  @NSManaged var id: NSNumber
  @NSManaged var checklistID: NSNumber // List ID
  @NSManaged private var status: NSNumber // Private status

  @NSManaged var list: List
  @NSManaged var parentTask: Task
  @NSManaged var tasks: NSSet

}
```
---

`NSManagedObject`

```
class Task: NSManagedObject {

  @NSManaged var id: NSNumber
  @NSManaged var checklistID: NSNumber // List ID
* @NSManaged private var status: NSNumber // Private status

  @NSManaged var list: List
  @NSManaged var parentTask: Task
  @NSManaged var tasks: NSSet

}
```
---

The private status is accessible to outside world via an *Enum*. This so that the value of the variable remains valid, always.

```
enum TaskStatus: Int {
  case Open
  case Closed
  case Invalidated
  case Unknown
}
```
```
extension Task {
  var taskStatus: TaskStatus {
    get {
      if let s = TaskStatus(rawValue: status.integerValue) {
        return s
      } else {
        return .Unknown
      }
    }
    set {
      status = newValue.rawValue as NSNumber
    }
  }
}

```

[Note]: The new accessor is made available via an extension so that it doesn't pollute the Object file.
---
class: center, middle

Add slide related to optionality of fields on an NSManagedObject.

The optionality can be changed from `xcdatamodeld`.
---
Extension 1

```
extension NSManagedObject {

  class func entityName() -> String {
    return NSStringFromClass(self).componentsSeparatedByString(".").last!
  }

}
```

Get entity name for a NSManagedObject.
---
Extension 2

```
extension NSManagedObject {

  class func object(moc: NSManagedObjectContext, predicate: NSPredicate?) -> NSManagedObject? {
    let req = NSFetchRequest(entityName: entityName())
    req.predicate = predicate

    guard let result = try? moc.executeFetchRequest(req) else {
      logger.error("Error getting object of entity \(self)")
      return nil
    }

    assert(result.count <= 1)
    return result.first as? NSManagedObject
  }

}
```

Get an object using a predicate along with `NSManagedObjectContext`.
---
Getting a Task becomes:

```
Task.object(moc, predicate: nil)
* as! Task // Ugh!
```
---
Extension 3

```
extension NSManagedObject {

  class func confidentObject(moc: NSManagedObjectContext, predicate: NSPredicate?) -> NSManagedObject {
    if let l = object(moc, predicate: predicate) {
      return l
    } else {
      return NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: moc)
    }
  }

}
```

Get an object confidently i.e. if it doesn't exist, create one and return it.
---
Extension 4

Using extension on `NSPredicate`
```
private extension NSPredicate {
  private convenience init(id: NSNumber) {
    self.init(format: "id == %@", argumentArray: [id])
  }
}
```

```
// MARK: - Works only on objects that have an id property.
extension NSManagedObject {
  class func confidentObject(moc: NSManagedObjectContext, id: NSNumber) -> NSManagedObject {
    return confidentObject(moc, predicate: NSPredicate(id: id))
  }
}
```
---
class: center, middle

Now let us use protocol extensions to help us make these extension methods play a bit more nicely.
---
We create a protocol `Entity`. Any object that wants to work with our model layer is an Entity.

```
protocol Entity: class {
}
```

Note that the protocol inherits from `class`, meaning that only classes can inherit from this protocol.

This is based on the assumption that `struct` and `enum` would never be enough to act like an Entity.
---
Once we have our class protocol, we create the Extension 1:

```
protocol Entity: class {
  static func entityName() -> String
}
```
```
extension Entity {

  static func entityName() -> String {
    return NSStringFromClass(self).componentsSeparatedByString(".").last!
  }

}
```
Do note that this is the default implementation for the protocol method. Any conforming class can still override it (without explicitly saying override).
---
Now the Extension 2

```
protocol Entity: class {

  static func object(moc: NSManagedObjectContext, predicate: NSPredicate?) -> Self?

}
```
```
extension Entity {
  static func object(moc: NSManagedObjectContext, predicate: NSPredicate?) -> Self? {
    let req = NSFetchRequest(entityName: entityName())
    req.predicate = predicate

    guard let result = try? moc.executeFetchRequest(req) else {
      logger.error("Error getting object of entity \(Self)")
      return nil
    }

    assert(result.count <= 1)
    return result.first as? Self
  }
}
```
---
class: center, middle

###A gotcha I consider a boon

Since the protocol extension method returns an instance of type `Self?`, the Swift compiler would not allow any non-final class to use this default implementation!

This because, any non-final class `C` is unable to say that when `C` and its subclass `S` conform to the protocol, what type is `Self`.

---
Getting a `Task` now becomes:

```
let task = Task.object(moc, predicate: nil) // Task?
```

Of course

```
extension Task: Entity {
	// Yes, empty implementation.
	// We are using the default implementation provided by the
	// protocol extensions.
}
```
---
Extension 3

```
protocol Entity: class {

  static func confidentObject(moc: NSManagedObjectContext, predicate: NSPredicate?) -> Self

}
```
```
extension Entity {

  static func confidentObject(moc: NSManagedObjectContext, predicate: NSPredicate?) -> Self {
    if let l = object(moc, predicate: predicate) {
      return l
    } else {
      return NSEntityDescription.insertNewObjectForEntityForName(
*     	entityName(), // Swift compiler knows about this method
        inManagedObjectContext: moc)
        as! Self // Typecast the raw NSManagedObject to our own type.
    }
  }

}
```
---
Extension 4

This is a bit tricky, because this extension demands the `NSManagedObject` to have a property named `id`.
This might not be true for all our NSManagedObjects'.

We didn't have an option before! The extension has to be on NSManagedObject, otherwise we need to make a superclass for all NSManagedObjects that define `id`. (Double Ugh!)
---
We take the option of creating a new protocol (because we can!)

```
protocol EntityWithID: Entity {
  static func confidentObject(moc: NSManagedObjectContext, id: NSNumber) -> Self
}
```

Notice how shamelessly the protocol inherits from `Entity`.

Readability: Any class conforming to `EntityWithID` automagically conforms to `Entity`! Exactly what we wanted to convey to our code reader.

Also, an `EntityWithID` can still get an object using custom predicate, `confidentObject(moc: predicate:)`.
---
Finishing:

```
private extension NSPredicate {
  private convenience init(id: NSNumber) {
    self.init(format: "id == %@", argumentArray: [id])
  }
}
```
```
extension EntityWithID {
  static func confidentObject(moc: NSManagedObjectContext, id: NSNumber) -> Self {
    return confidentObject(moc, predicate: NSPredicate(id: id))
  }
}
```

We have kept the convenience initializer private to this file since it should not be needed outside.
