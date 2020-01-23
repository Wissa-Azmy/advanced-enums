import UIKit

var str = "The Basics"

// Or to floating point (also note the fancy unicode in enum cases)
enum Constants: Double {
    case π = 3.14159
    case e = 2.71828
    case φ = 1.61803398874
    case λ = 1.30357
}

//For String and Int types, you can even omit the values and the Swift compiler will do the right thing:
enum Planet: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune  // mercury = 1, venus = 2, ... neptune = 8
}

enum CompassPoint: String {
    case north, south, east, west   // north = "north", ... west = "west"
}

//Swift supports the following types for the value of an enum:
// Integer
// Floating Point
// String
// Boolean
//You can support more types by implementing a specific protocol.

//If you want to access the values, you can do so with the rawValue property:
let bestDirection = CompassPoint.north
print(bestDirection.rawValue)
// prints "north is coming"


// However, there may also be a situation where you want to construct an enum case from an existing raw value.
// In that case, there's a special initializer for enums:

enum Movement: Int {
    case left = 0
    case right = 1
    case top = 2
    case bottom = 3
}
// returns a movement.Right case, as the raw value for that is 1
let rightMovement = Movement(rawValue: 1)


// MARK: - Nesting Enums
enum Character {
  case thief, warrior, knight
    
  enum Weapon {
    case bow, sword, lance, dagger
  }
  enum Helmet {
    case wooden, iron, diamond
  }
}

let character = Character.thief
let weapon = Character.Weapon.bow
let helmet = Character.Helmet.iron


// MARK: Associated Values
enum Trade {
    case buy(stock: String, amount: Int)
    case sell(stock: String, amount: Int)
}

func trade(with: Trade) {}

// You always have to initialize these cases with the associated values:
let transaction = Trade.buy(stock: "APPL", amount: 500)
trade(with: transaction)

// Use Pattern Matchig to access values
if case let Trade.buy(stock, amount) = transaction {
    print("buy \(amount) of \(stock)")
}

// Another way of writing this with two let statements:
if case Trade.buy(let stock, let amount) = transaction {
  print("buy \(amount) of \(stock)")
}

// Associated values do not require labels.
// You can just denote the types you'd like to see in your enum case.
enum Trade2 {
   case buy(String, Int)
   case sell(String, Int)
}

// Initialize without labels
let trade = Trade2.sell("APPL", 500)



/**** Use Case Examples ****/
// Associated Values can be used in a variety of ways.
// What follows is a list of short examples in no particular order.

// Cases can have different values
enum UserAction {
  case openURL(url: NSURL)
  case switchProcess(processId: UInt32)
  case restart(time: NSDate?, intoCommandLine: Bool)
}

// Or imagine you're implementing a powerful text editor that allows you to have
// multiple selections, like Sublime Text here:
// https://www.youtube.com/watch?v=i2SVJa2EGIw
enum Selection {
  case none
  case single(Range<Int>)
  case multiple([Range<Int>])
}

// Or mapping different types of identifier codes
enum Barcode {
    case UPCA(numberSystem: Int, manufacturer: Int, product: Int, check: Int)
    case QRCode(productCode: String)
}

// Or, imagine you're wrapping a C library, like the Kqeue BSD/Darwin notification
// system: https://www.freebsd.org/cgi/man.cgi?query=kqueue&sektion=2
enum KqueueEvent {
    case userEvent(identifier: UInt, fflags: [UInt32], data: Int)
    case readFD(fd: UInt, data: Int)
    case writeFD(fd: UInt, data: Int)
    case vnodeFD(fd: UInt, fflags: [UInt32], data: Int)
    case errorEvent(code: UInt, message: String)
}

// Finally, all user-wearable items in an RPG could be mapped with one
// enum, that encodes for each item the additional armor and weight
// Now, adding a new material like 'Diamond' is just one line of code and we'll have the option to add several new Diamond-Crafted wearables.
enum Wearable {
    enum Weight: Int {
        case light = 1, mid = 4, heavy = 10
    }
    enum Armor: Int {
        case light = 2, strong = 8, heavy = 20
    }
    case helmet(weight: Weight, armor: Armor)
    case breastplate(weight: Weight, armor: Armor)
    case shield(weight: Weight, armor: Armor)
}

let woodenHelmet = Wearable.helmet(weight: .light, armor: .light)


// MARK: - Methods & Properties
// Swift enum types can have methods and properties attached to them.
// This works exactly like you'd do it for class or struct types. Here is a very simple example:
enum Transportation {
  case car(Int)
  case train(Int)

  // The main difference to struct or class types is that you can switch on self within the method in order to calculate the output.
  func distance() -> String {
    switch self {
    case .car(let miles): return "\(miles) miles by car"
    case .train(let miles): return "\(miles) miles by train"
    }
  }
}

let vehicle = Transportation.car(50)
print(vehicle.distance())


/****  Properties ****/
// Enums don't allow for adding stored properties.
// This means the following does not work:
/*
enum Device {
  case iPad, iPhone
  
  let introduced: Int
}
*/

// Even though you can't add actual stored properties to an enum, you can still create computed properties.
// Their contents, of course, can be based on the enum value or enum associated value. They're read-only though.
enum Device {
  case iPad, iPhone

  var introduced: Int {
    switch self {
    case .iPhone: return 2007
    case .iPad: return 2010
    }
  }
}
// This works great as long as the year of the introduction of an Apple device never changes.
// You couldn't use this if you'd like to store mutable / changing information.
// In those cases you'd always use associated values.

// Also, you can always still add properties for easy retrieval of the associated value:
extension Transportation {
  var speedInKm: Float {
    switch self {
    case .car(let miles): return Float(miles) * 1.6
    case .train(let miles): return Float(miles) * 1.6
    }
  }
}


/**** Static Methods ****/
// You can also have static methods on enums, i.e. in order to create an enum from a non-value type.
enum AppleDevice {
  static var newestDevice: AppleDevice {
    return .appleWatch
  }

  case iPad, iPhone, appleWatch
}


/**** Mutating Methods ****/
// Methods can be declared mutating. They're then allowed to change the case of the underlying self parameter. Imagine a lamp that has three states: off, low, bright where low is low light and bright a very strong light. We want a function called next that switches to the next state:

enum TriStateSwitch {
    case off, low, bright
    mutating func next() {
        switch self {
        case .off:
            self = .low
        case .low:
            self = .bright
        case .bright:
            self = .off
        }
    }
}

var ovenLight = TriStateSwitch.low
ovenLight.next()
// ovenLight is now equal to .bright
ovenLight.next()
// ovenLight is now equal to .off
