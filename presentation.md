class: center, middle

# Swifty Core Data

####Use Swift features to help with Core Data

.footnote[.red.bold[*] You don't need to be using Core Data currently to understand the presentation.]

???

Title slide

---

name: Agenda

# Agenda

1. NSManagedObject extensions: Protocol extensions to the rescue
2. Using Protocols to hide away persistence layer
3. Testing the created protocols
4. Swift 3's impact on these ideas

???

The agenda to be followed in the presentation
---
class: middle

```
class Task: NSManagedObject {
  @NSManaged var id: NSNumber
  @NSManaged var text: String
}
```

???
Let us take a sample class `Task` which we want to save in Core Data.
Class has an `id` and text.
---
```
extension Task {
  class func object(managedObjectContext: NSManagedObjectContext,
                    predicate: NSPredicate?)
                    -> Task? {
    let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? Task
  }
}
```

We define a required method:

???
We define a single method on class `Task` which gives back an optional `Task` based on provided predicate.
The method

---
class: middle

```
extension Task {
* class func object(managedObjectContext: NSManagedObjectContext,
                    predicate: NSPredicate?)
                    -> Task? {
    let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? Task
  }
}
```

####1. This function is tied to `NSManagedObjectContext` and would need a rewrite if we decide to change the persistence layer.

---
class: middle

```
extension Task {
  class func object(managedObjectContext: NSManagedObjectContext,
                    predicate: NSPredicate?)
*                    -> Task? {
    let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? Task
  }
}
```

####2. This function would need to be copied to any other class too that requires it.

---
class: center, middle

So we have a non-reusable strongly tied method.

--

####Let's fix it...

---
class: middle

```
extension NSManagedObject {
  class func managedObject(managedObjectContext: NSManagedObjectContext,
                           predicate: NSPredicate?)
                           -> NSManagedObject? {
    let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? NSManagedObject
  }
}
```

####We move this function to an extension on `NSManagedObject` instead.
*Easy, Right?*

---
class: middle

```
*extension NSManagedObject {
  class func managedObject(managedObjectContext: NSManagedObjectContext,
                           predicate: NSPredicate?)
                           -> NSManagedObject? {
    let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? NSManagedObject
  }
}
```

####1. Every `NSManagedObject` class gets it, by default, even if we don't want it to.

---
class: middle

```
extension NSManagedObject {
* class func managedObject(managedObjectContext: NSManagedObjectContext,
                           predicate: NSPredicate?)
                           -> NSManagedObject? {
    let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? NSManagedObject
  }
}
```

####2. We are still tied up with Core Data.
####Function `managedObject` is not available to classes not using Core Data as persistence layer.

---
class: middle

```
extension NSManagedObject {
  class func managedObject(managedObjectContext: NSManagedObjectContext,
                           predicate: NSPredicate?)
*                          -> NSManagedObject? {
    let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? NSManagedObject
  }
}
```

####3. The return type of the function is `NSManagedObject`. So whenever you want to use it, you type cast it.

```
Task.managedObject(mainManagedObjectContext, predicate: nil)
* as! Task
```

---
class: middle

```
extension NSManagedObject {
  extension NSManagedObject {
    class func managedObject(managedObjectContext: NSManagedObjectContext,
                             predicate: NSPredicate?)
                             -> NSManagedObject? {
*   let fetchRequest = NSFetchRequest(entityName: "Task")
    fetchRequest.predicate = predicate
    guard let result = try? managedObjectContext.executeFetchRequest(fetchRequest) else {
      print("Error getting object of entity \(self)")
      return nil
    }
    assert(result.count <= 1)
    return result.first as? NSManagedObject
  }
}
```

####4. That is *NOT* the name of all our entities.

---
class: middle

Let us just fix the last one, it isn't so bad..

```
extension NSManagedObject {
  class func entityName() -> String {
    return NSStringFromClass(self)
*   .componentsSeparatedByString(".").last! // *
  }
}
```

.footnote[.simple[*] Module name is prepended to string representations of classes in swift]

---
class: center, middle

###Hmm, so extending NSManagedObject wasn't a very good solution..
--

*I wouldn't have added so many negative points to my solution! So obvious 😁*
---
class: center, middle

Enter,

#Protocol Extensions
##Protocol Extensions
###Protocol Extensions
...

---
class: center, middle

But first we need a protocol!

What better than to call it

#Entity

---

Any object that wants to work with our model layer is now an Entity.

```
protocol Entity {
}
```

---

```
protocol Entity {
  static func name() -> String
}
```

The first requirement of the protocol is to have a name.

---

We know what this method has to do for `NSManagedObject`. Let us add this to an extension, **on protocol**.

```
extension Entity
* where Self: NSManagedObject {
  static func entityName() -> String {
    return NSStringFromClass(self).componentsSeparatedByString(".").last!
  }
}
```

---

```
protocol Entity {
  static func object(managedObjectContext: NSManagedObjectContext,
                     predicate: NSPredicate?)
                     -> NSManagedObject?
}
```

???

Tied to core data
Returns a NSManagedObject
---

```
protocol Entity {
  static func object(managedObjectContext: NSManagedObjectContext,
                     predicate: NSPredicate?)
                     -> Self?
}
```

---

```
protocol Entity {
  static func object(managedObjectContext: NSManagedObjectContext,
                     predicate: NSPredicate?)
*                    -> Self?
}
```

```
Task.managedObject(mainManagedObjectContext, predicate: nil)
```

???
The returned object is now of correct type.
---

`NSManagedObjectContext`
##Why?

???

We are still asking the object from a NSManagedObjectContext. Skip that and lets start using context.

---
class: center, middle

##Welcome associatedType

---

```
protocol Entity {
* associatedType Context
* static func object(context: Context,
                     predicate: NSPredicate?)
                     -> Self?
}
```

Finally no trace of Core data!

???
explain a bit about associatedType and how it is to be implemented by conforming classes.
Get ready to implement a default implementation.

---

```
protocol Entity {
  associatedType Context
  static func object(predicate: NSPredicate?,
*                    context: Context)
                     -> Self?
}
```

I would have liked to keep it this way, but then I realized Apple keeps context as first param too.

```
func CGContextSetFlatness(_ c: CGContext?, _ flatness: CGFloat)
func CGContextSetLineDash(_ c: CGContext?, _ phase: CGFloat, _ lengths: UnsafePointer<CGFloat>, _ count: Int)
func CGContextSetInterpolationQuality(_ c: CGContext?, _ quality: CGInterpolationQuality)
//...
```

???

---

```
extension Entity where Context == NSManagedObjectContext {
  static func object(context: Context, predicate: NSPredicate?) -> Self? {
  let req = NSFetchRequest(entityName: entityName())
  req.predicate = predicate
  guard let result = try? context.executeFetchRequest(req) else {
    logger.error("Error getting object of entity \(self)")
    return nil
  }
  assert(result.count <= 1)
  return result.first as? Self
  }
}
```

---

```
extension Entity where Context == NSManagedObjectContext {
```

???
Explain that this is available only when context is NSManagedObjectContext

---

```
static func object(context: Context, predicate: NSPredicate?) -> Self? {
```

???
Explain that Context and NSManagedObjectContext are same because of previous statement.

---

```
let req = NSFetchRequest(entityName: entityName())
```

???
Explain that entityName() is given in protocol and thus safe to call by the extension method.

---

```
return result.first as? Self
```

???
Explain type cast required because `executeFetchRequest` returns `[AnyObject]`.

---

# Conformance

```
extension Task: Entity {
  typealias Context = NSManagedObjectContext
}
```

???
Explain how it gets entityName() and the default implementation for `object`.

---

##Gotcha #1

An associatedType can not be fulfilled by the protocol extension

???
And thus we require to do the typealias

---

##Gotcha #2

Since the protocol extension method returns an instance of type `Self?`, the Swift compiler would not allow any non-final class to use this default implementation!

???
This because, any non-final class `C` is unable to say that when `C` and its subclass `S` conform to the protocol, what type is `Self`.

---

Do note that this is the default implementation for the protocol method. Any conforming class can still override it (without explicitly saying override).

Now any class conforming to the protocol defines its own context to use. So your `Entity` could be using `NSUserDefaults` as Context and the protocol would not bat an eye!

---

```
final class Account {
  typealias Context = NSUserDefaults

  static func entityName() -> String {
    return "KeyForAccountInUserDefaults"
  }

  class func object(context: Context,
                    predicate: NSPredicate?) -> Account? {
    return context.objectForKey(entityName()) as? Account
  }
}
```

???
Explain how the persistence layer has been abstracted out. This class's object
can now be kept in an array [Entity] and worked on by functions.
