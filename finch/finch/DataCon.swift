//
//  DataCon.swift
//  finch
//
//  Created by Matthew Patterson on 6/8/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate

//struct Countdown: Sequence, IteratorProtocol {
//    var count: Int
//    
//    mutating func next() -> Int? {
//        if count == 0 {
//            return nil
//        } else {
//            defer { count -= 1 }
//            return count
//        }
//    }
//}

protocol InitializableNumeric : InitializableFromString, Numeric {
    // is this insane?
}
//<T where T: SomeClass, T: SomeProtocol>
// implementing class to have ARC
// class DataCon<Element where Element:Numeric, Element:InitializableFromString>
class DataCon<Element:InitializableFromString>
    :
    Equatable,
    ExpressibleByArrayLiteral,
    IteratorProtocol,
    Sequence,
    CustomStringConvertible,
    LosslessStringConvertible,
    CustomDebugStringConvertible where Element:Numeric
    //where Element:Numeric, Element:InitializableFromString
{

    var debugDescription: String {
        return "<DataCon: > \(self.data.description)"
    }
    
    var description: String {
        return self.data.description
    }

    static func == (lhs: DataCon<Element>, rhs: DataCon<Element>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for (a, b) in zip(lhs, rhs) {
            guard a == b else {
                return false
            }
        }
        return true
    }
    
    var data: ContiguousArray<Element>
    typealias ArrayLiteralElement = Element

    subscript(idx: Int) -> Element {
        return data[idx]
    }
    
    // MARK: Sequence, IteratorProtocol
    var count: Int = 0
    func next() -> Element? {
        if count == data.count {
            return nil
        } else {
            defer { count += 1 }
            return self[count]
        }
    }
    
    required init(arrayLiteral elements: Element...) {
        data = ContiguousArray<Element>(elements)
    }

    init(elements: [Element]) {
        data = ContiguousArray<Element>(elements)
    }

    required init?(_ description: String) {
        let strings: [String] = description.removingDelimiters().components(separatedBy: String.VectorSeparators)
        let elements = strings.filter{(x: String)->Bool in return x.count > 0}.map{(x: String)->Element in return Element(x)!}
        data = ContiguousArray<Element>(elements)
    }
}
