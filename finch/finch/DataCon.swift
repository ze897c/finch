//
//  DataCon.swift
//  finch
//
//  Created by Matthew Patterson on 6/8/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate


protocol DaCoEl: LosslessStringConvertible, Numeric {
    
}

extension Double: DaCoEl {}
extension Int: DaCoEl {}
extension UInt: DaCoEl {}

// implementing class to have ARC
class DataCon<Element: DaCoEl>
    //class DataCon<Element:LosslessStringConvertible>
    :
    CustomDebugStringConvertible,
    CustomStringConvertible,
    Equatable,
    ExpressibleByArrayLiteral,
    LosslessStringConvertible,
    Sequence
//    where Element:Numeric
{

    typealias Index = Int
    typealias Indices = Range<DataCon.Index>
    typealias ArrayLiteralElement = Element
    var data: ContiguousArray<Element>

    let startIndex: DataCon.Index
    var endIndex: DataCon.Index {
        guard data.count > 0 else {
            return 0 // bogus?
        }
        return startIndex + Int(data.count) - 1
    }
    var count: Int {
        return Int(data.count)
    }
    
    var indices: Range<DataCon.Index> {
        return startIndex..<endIndex
    }

    var debugDescription: String {
        return "<DataCon: > \(self.data.description)"
    }
    
    var description: String {
        return self.data.description
    }

    func formIndex(before i: inout DataCon.Index) {
        i -= 1
    }

    func index(after i: DataCon.Index) -> DataCon.Index {
        return i + 1
    }
    
    
    static func == (lhs: DataCon<Element>, rhs: DataCon<Element>) -> Bool {
        guard lhs.startIndex == rhs.startIndex && lhs.endIndex == rhs.endIndex else {
            return false
        }
        for idx in lhs.startIndex..<lhs.endIndex {
            guard lhs.data[idx] == rhs.data[idx] else {
                return false
            }
        }
        return true
    }

    subscript(idx: DataCon.Index) -> Element {
        get{
            return data[Int(idx)]
        }
        set {
            data[Int(idx)] = newValue
        }
    }
    
    init(repeating rep: Element, count capacity: Int) {
        data = ContiguousArray<Element>(repeating: rep, count: capacity)
        startIndex = 0
    }

    init(DataCon otro: DataCon<Element>, start: DataCon.Index?) {
        data = otro.data
        startIndex = start ?? otro.startIndex
    }
    
    init(contiguousArray whoreofbabylon: ContiguousArray<Element>, start: DataCon.Index = 0) {
        data = whoreofbabylon
        startIndex = start
    }
    
    required init(arrayLiteral elements: Element...) {
        data = ContiguousArray<Element>(elements)
        startIndex = 0
    }

    init(elements chickenfucker: [Element]) {
        data = ContiguousArray<Element>(chickenfucker)
        startIndex = 0
    }

    required init?(_ description: String) {
        let strings: [String] = description.removingDelimiters().components(separatedBy: String.VectorSeparators)
        let elements = strings.filter{(x: String)->Bool in return x.count > 0}.map{(x: String)->Element in return Element(x)!}
        data = ContiguousArray<Element>(elements)
        startIndex = 0
    }
    
    // Higher order functions -- maps, reduces, filters, etc. : behavior of these should reflect what is expected of the class
    // for example, *map* is removed to prevent *nil* elements in something passed to BLAS
    func makeIterator() -> DataConIterator<Element> {
        return DataConIterator(self)
    }
    

    func mapTo<ResultElement>(f: (DataCon.Element) -> ResultElement) -> DataCon<ResultElement> {
        // below, _let_ should be _var_ IMO, but SILGEN complains
        let rex: DataCon<ResultElement> = DataCon<ResultElement>(repeating: 0 as ResultElement, count: count)
        for idx in startIndex ..< endIndex {
            rex.data[idx] = f(data[idx])
        }
        return rex
    }
    
    func compactMapTo<T: DaCoEl>(f: (Element) -> T?) -> DataCon<T>? {
        //let fuckingfucker:T = T("0")!
        //let frank:DataCon<T> = DataCon<T>(repeating: fuckingfucker, count: count)
        let frank:DataCon<T> = DataCon<T>(repeating: T("0")!, count: count)
        
        frank.data = ContiguousArray<T>(data.compactMap {f($0)})
        //let elements: ContiguousArray<T> = ContiguousArray(data.compactMap {f($0)})

        guard frank.data.count > 0 else {
            return nil
        }
        //frank
        let rexi = DataCon<T>(DataCon: frank, start: 0)
        //let rex: DataCon<T> = DataCon(contiguousArray: elements)
        return rexi
    }

    // act like a *Collection*, but only where appropriate

//    Returns the distance between two indices.
//    Required. Default implementations provided.
//    Beta
//    func distance(from: Self.Index, to: Self.Index) -> Int

//    Returns the first index where the specified value appears in the collection.
//    Beta
//    func firstIndex(of: Self.Element) -> Self.Index?

//    Returns the first index in which an element of the collection satisfies the given predicate.
//    Beta
//    func firstIndex(where: (Self.Element) -> Bool) -> Self.Index?

//    Replaces the given index with its successor.
//    Required. Default implementation provided.
//    Beta
//    func formIndex(after: inout Self.Index)

//    Returns an index that is the specified distance from the given index.
//    Required. Default implementations provided.
//    Beta
//    func index(Self.Index, offsetBy: Int) -> Self.Index

//    Returns an index that is the specified distance from the given index, unless that distance is beyond a given limiting index.
//    Required. Default implementations provided.
//    Beta
//    func index(Self.Index, offsetBy: Int, limitedBy: Self.Index) -> Self.Index?

//    Returns a subsequence from the start of the collection through the specified position.
//    Required. Default implementation provided.
//    Beta
//    func prefix(through: Self.Index) -> Self.SubSequence

//    Returns a subsequence from the start of the collection up to, but not including, the specified position.
//    Required. Default implementation provided.
//    Beta
//    func prefix(upTo: Self.Index) -> Self.SubSequence

//    Returns a random element of the collection.
//    Beta
//    func randomElement() -> Self.Element?

//    Returns a random element of the collection, using the given generator as a source for randomness.
//    Required. Default implementation provided.
//    Beta
//    func randomElement<T>(using: inout T) -> Self.Element?


//    Returns a subsequence from the specified position to the end of the collection.
//    Required. Default implementation provided.
//    func suffix(from: Self.Index) -> Self.SubSequence

}

struct DataConIterator<Element:DaCoEl>
    :
    IteratorProtocol
    //where Element: Numeric
{
    let daco: DataCon<Element>
    var idx: DataCon<Element>.Index
    
    init(_ daco: DataCon<Element>) {
        self.daco = daco
        idx = self.daco.startIndex
    }
    
    mutating func next() -> Element? {
        guard idx <= daco.endIndex else {
            return nil
        }
        defer { idx += 1 }
        return daco[idx]
    }
}
