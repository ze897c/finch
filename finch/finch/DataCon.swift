//
//  DataCon.swift
//  finch
//
//  Created by Matthew Patterson on 6/8/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate


//protocol InitializableNumeric : InitializableFromString, Numeric {
//    // is this insane?
//}

// implementing class to have ARC
// class DataCon<Element where Element:Numeric, Element:InitializableFromString>
class DataCon<Element:LosslessStringConvertible>
    :
    Equatable,
    ExpressibleByArrayLiteral,
    IteratorProtocol,
    Collection,
    CustomStringConvertible,
    LosslessStringConvertible,
    CustomDebugStringConvertible where Element:Numeric
{

    let startIndex: Int = 0
    var endIndex: Int {
        return data.count - 1
    }
    var count: Int = 0
    
    var debugDescription: String {
        return "<DataCon: > \(self.data.description)"
    }
    
    var description: String {
        return self.data.description
    }

    func index(after i: Int) -> Int {
        return i + 1
    }

    //    static func == (lhs: [Element], rhs: [Element]) -> Bool {
    //
    //    }
    
    static func == (lhs: DataCon<Element>, rhs: DataCon<Element>) -> Bool {
        guard lhs.data.count == rhs.data.count else {
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
        count = data.count
    }

    init(elements: [Element]) {
        data = ContiguousArray<Element>(elements)
        count = data.count
    }

    required init?(_ description: String) {
        let strings: [String] = description.removingDelimiters().components(separatedBy: String.VectorSeparators)
        let elements = strings.filter{(x: String)->Bool in return x.count > 0}.map{(x: String)->Element in return Element(x)!}
        data = ContiguousArray<Element>(elements)
        count = data.count
    }
}
