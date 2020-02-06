//: [Previous](@previous)

import UIKit

var str = "Advanced Enums"

// MARK: - Enums with Protocols

protocol CustomStringConvertible {
  var description: String { get }
}


enum Trade: CustomStringConvertible {
   case buy, sell
   var description: String {
       switch self {
       case .buy: return "We're buying something"
       case .sell: return "We're selling something"
       }
   }
}


// Some protocol implementations may need internal state handling to cope with the requirements.
protocol AccountCompatible {
  var remainingFunds: Int { get }
  mutating func addFunds(amount: Int) throws
  mutating func removeFunds(amount: Int) throws
}

// However, you can't add properties like var remainingFunds: Int to an enum, so how would you model that?
// The answer is actually easy, you can use associated values for this:
enum Account {
  case empty
  case funds(remaining: Int)
  case credit(amount: Int)

  var remainingFunds: Int {
    switch self {
    case .empty: return 0
    case .funds(let remaining): return remaining
    case .credit(let amount): return amount
    }
  }
}


// To keep things clean, we can then define the required protocol functions in a protocol extension on the enum:
extension Account: AccountCompatible {

  mutating func addFunds(amount: Int) {
    var newAmount = amount
    if case let .funds(remaining) = self {
      newAmount += remaining
    }
    if newAmount < 0 {
      self = .credit(amount: newAmount)
    } else if newAmount == 0 {
      self = .empty
    } else {
      self = .funds(remaining: newAmount)
    }
  }

  mutating func removeFunds(amount: Int) throws {
    self.addFunds(amount: amount * -1)
  }

}

var account = Account.funds(remaining: 20)
account.addFunds(amount:10)
try account.removeFunds(amount:15)


// MARK: - Extensions

// We can extend the standard library Optional type in order to add useful extensions.
extension Optional {
    /// Returns true if the optional is empty
    var isNil: Bool {
        switch self {
        case .none: return true
        default:
            return false
        }
    }
}

var optionalValue: Int?

if optionalValue.isNil {
    print("The variable is nil")
}


// MARK: - Generic Enums

// The simplest example comes straight from the Swift standard library, namely the Optional type.
// You probably mostly use it with optional chaining (?), if let, guard let, or switch, but syntactically you can also use Optionals like so:

let aValue = Optional<Int>.some(5)
let noValue = Optional<Int>.none
if noValue == Optional.none { print("No value") }

//If you look at the code above, you can probably guess that internally the Optional is defined as follows 1:
// Simplified implementation of Swift's Optional
enum MyOptional<T> {
  case some(T)
  case none
}


// Finally, all the type constraints that work on classes and structs in Swift also work on enums.
// Here, we have a type Bag that is either empty or contains an array of elements.
// Those elements have to be Equatable.

enum Bag<T: Sequence> where T.Iterator.Element: Equatable {
    case empty
    case full(contents: [T])
}


// MARK: - Recursive / Indirect Types
//Indirect types allow you to define enums where the associated value of a case is the very same enum again.

// Consider that you want to define a file system representations with files and folders containing files.
enum FileNode {
  case file(name: String)
  indirect case folder(name: String, files: [FileNode])
}

// The indirect keyword tells the compiler to handle this enum case indirectly.
// You can also add the keyword for the whole enum.

//As an example imagine mapping a binary tree:
indirect enum Tree<Element: Comparable> {
    case empty
    case node(Tree<Element>,Element,Tree<Element>)
}



// MARK: - Custom Data Types

// If we neglect associated values, then the value of an enum can only be an Integer, Floating Point, String, or Boolean.
// If you need to support something else, you can do so by implementing the -"ExpressibleByStringLiteral"- protocol which allows the type in question to be serialized to and from String.

// As an example, imagine you'd like to store the different screen sizes of iOS devices in an enum:
enum Devices: CGSize {
   case iPhone3GS = "320,480"
   case iPhone5 = "320,568"
   case iPhone6 = "375,667"
   case iPhone6Plus = "414,736"
}
// However, this doesn't compile because CGSize is not a literal and can't be used as an enum value.
// Instead, what you need to do is add a type extension for the ExpressibleByStringLiteral protocol.


// The protocol requires us to implement an initializer that receives a String.
// Next, we need to take this String an convert it into a CGSize. Not any String can be a CGSize.
// So if the value is wrong, we will crash with an error as this code will be executed by Swift during application startup.
// Our string format for sizes is: width, height.
extension CGSize: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let components = value.split(separator: ",")
        guard components.count == 2,
            let width = Int(components[0]),
            let height = Int(components[1])
            else { fatalError("Invalid Format \(value)") }
        self.init(width: width, height: height)
    }
}
// The initial values have to be written as a String, since that's what the enum will use.
// (remember, we complied with ExpressibleByStringLiteral protocol, so that the String can be converted to our CGSize type.)

// Keep in mind that in order to get the actual CGSize value, we have to access the rawValue of the enum.
let a = Devices.iPhone5
let b = a.rawValue
print("the phone size string is \(a), width is \(b.width), height is \(b.height)")
// This works, because we explicitly told Swift that a CGSize can be created from any String.


// MARK: - Comparing Enums

// Just like need to compare strings ("world" == "hello") or numbers you sometimes also need to compare enums.
// For very simple ones, like the following, this is easy as Swift takes care of it:
enum Toggle {
  case on, off
}

Toggle.on == Toggle.off

// But what if you have a more complex enum with associated values like this one?
enum Character {
  case warrior(name: String, level: Int, strength: Int)
  case wizard(name: String, magic: Int, spells: [String])
}

// If you'd try to compare to instances of Character Swift would complain.
// By default, it doesn't know how to compare enum types that have associated values.
// However, you can explicitly tell Swift to just compare all the values of each case and if they're the same, then the types are equal.
// To do that, you'd just add an empty conformance to the Equatable protocol:
enum Character3: Equatable {
  case warrior(name: String, level: Int, strength: Int)
  case wizard(name: String, magic: Int, spells: [String])
}
// This only works if all the values in your cases are also Equatable. This works in our example as Int, String and arrays of String are Equatable by default.

// If that is not an option, you an always implement a custom Equatable conformance:

// Not Equatable Stock
struct Stock {
    let name: String
}

enum Trade2 {
    case buy(stock: Stock, amount: Int)
    case sell(stock: Stock, amount: Int)
}

func ==(lhs: Trade2, rhs: Trade2) -> Bool {
   switch (lhs, rhs) {
   case let (.buy(stock1, amount1), .buy(stock2, amount2))
    where stock1.name == stock2.name && amount1 == amount2:
         return true
   case let (.sell(stock1, amount1), .sell(stock2, amount2))
    where stock1.name == stock2.name && amount1 == amount2:
         return true
   default: return false
   }
}


// MARK: - Custom Initializers

// Imagine you'd want to initialize an enum with custom data. In our example we have a Device enum that represents Apple devices and we'd like to also initialize them with non-standard names. Here's the enum:

enum DevicesByApple {
  case appleWatch
}
// Now if a user accidentally enters iWatch as their device, we still want to map this to the correct AppleWatch case. To do that, we will implement a custom initializer that sets self to the correct type:

enum DevicesByApple {
    case appleWatch
    init?(term: String) {
      if term == "iWatch" {
          self = .appleWatch
      } else {
          return nil
      }
    }
}
// In the above example, we used a failable initializer. However, normal initializers work just as well:

enum NumberCategory {
   case small
   case medium
   case big
   case huge

   init(number n: Int) {
        if n < 10000 { self = .small }
        else if n < 1000000 { self = .medium }
        else if n < 100000000 { self = .big }
        else { self = .huge }
   }
}
