//: [Previous](@previous)

import Foundation

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
