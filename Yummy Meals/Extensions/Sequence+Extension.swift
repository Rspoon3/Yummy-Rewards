//
//  Sequence+Extension.swift
//  Yummy Meals
//
//  Created by Richard Witherspoon on 10/1/22.
//

import Foundation

public extension Sequence {
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>,
        _ comparator: (_ lhs: Value, _ rhs: Value) -> Bool = (<)) -> [Element]{
            sorted { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
        }
    
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>, increasing: Bool) -> [Element]{
        if increasing {
            return sorted { $0[keyPath: keyPath]  <  $1[keyPath: keyPath] }
        } else {
            return sorted { $0[keyPath: keyPath]  >  $1[keyPath: keyPath] }
        }
    }
    
    mutating func sort<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>,
        _ comparator: (_ lhs: Value, _ rhs: Value) -> Bool = (<)) {
            self = sorted { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) } as! Self
        }
    
    mutating func sort<Value: Comparable>(by keyPath: KeyPath<Element, Value>, increasing: Bool) {
        if increasing {
            self = sorted { $0[keyPath: keyPath]  <  $1[keyPath: keyPath] } as! Self
        } else {
            self = sorted { $0[keyPath: keyPath]  >  $1[keyPath: keyPath] } as! Self
        }
    }
    
    func max<T: Comparable>(by predicate: (Element) -> T)  -> Element? {
        self.max(by: { predicate($0) < predicate($1) })
    }
    
    func min<T: Comparable>(by predicate: (Element) -> T)  -> Element? {
        self.min(by: { predicate($0) < predicate($1) })
    }
}
