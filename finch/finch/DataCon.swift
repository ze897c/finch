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
    Sequence,
    //BidirectionalCollection, // breaks: *Collection.map<Element>* doe not call *makeIterator()*; rely on *Sequence*?
    //LazyCollectionProtocol,
    CustomStringConvertible,
    LosslessStringConvertible,
    CustomDebugStringConvertible
    where Element:Numeric
{
    
    typealias ArrayLiteralElement = Element
    var data: ContiguousArray<Element>

    let startIndex: Int
    let endIndex: Int
    let count: Int

    var debugDescription: String {
        return "<DataCon: > \(self.data.description)"
    }
    
    var description: String {
        return self.data.description
    }

//    func index(before i: Int) -> Int {
//        return i - 1
//    }
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    func makeIterator() -> DataConIterator<Element> {
        return DataConIterator(self)
    }
    
    static func == (lhs: DataCon<Element>, rhs: DataCon<Element>) -> Bool {
        guard lhs.startIndex == rhs.startIndex && lhs.endIndex == rhs.endIndex else {
            return false
        }
        for (a, b) in zip(lhs, rhs) {
            guard a == b else {
                return false
            }
        }
        return true
    }
    

    subscript(idx: Int) -> Element {
        return data[idx]
    }
    
    init(DataCon otro: DataCon<Element>) {
        data = otro.data // still wrong: want pointer to same raw storage
        startIndex = 0
        endIndex = data.count - 1
        count = data.count
    }
    
    required init(arrayLiteral elements: Element...) {
        data = ContiguousArray<Element>(elements)
        startIndex = 0
        endIndex = data.count - 1
        count = data.count
    }

    init(elements: [Element]) {
        data = ContiguousArray<Element>(elements)
        startIndex = 0
        endIndex = data.count - 1
        count = data.count
    }

    required init?(_ description: String) {
        let strings: [String] = description.removingDelimiters().components(separatedBy: String.VectorSeparators)
        let elements = strings.filter{(x: String)->Bool in return x.count > 0}.map{(x: String)->Element in return Element(x)!}
        data = ContiguousArray<Element>(elements)
        startIndex = 0
        endIndex = data.count - 1
        count = data.count
    }
}

struct DataConIterator<Element:LosslessStringConvertible>
    :
    IteratorProtocol
    where Element: Numeric
{
    let daco: DataCon<Element>
    var idx: Int
    
    init(_ daco: DataCon<Element>) {
        self.daco = daco
        idx = self.daco.startIndex
    }
    
    mutating func next() -> Element? {
        if idx == daco.endIndex {
            return nil
        } else {
            defer { idx += 1 }
            return daco[idx]
        }
    }
}
