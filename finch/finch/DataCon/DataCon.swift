//
//  DataCon.swift
//  finch
//
//  Created by Matthew Patterson on 6/8/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate

//extension Int: DaCoEl {}
//extension UInt: DaCoEl {}

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
    //var data: ContiguousArray<Element>
    let count: UInt
    let data: UnsafeMutablePointer<Element>
    
    let startIndex: DataCon.Index
    var endIndex: DataCon.Index {
        guard count > 0 else {
            return 0 // bogus?
        }
        return startIndex + DataCon.Index(count) - 1
    }
//    var count: DataCon.Index {
//        return DataCon.Index(data.count)
//    }
    
    var indices: Range<DataCon.Index> {
        return startIndex..<endIndex
    }

    var debugDescription: String {
        return "<DataCon: > \(self.description)"
    }

    var description: String {
        let sep: String = ", "
        var rex: String = "["
        for x in self {
            print(x, separator: "<><>,,", terminator: sep, to: &rex)
//            print(v, separator: "<><>,,", terminator: sep, to: &rex)
            //print(items: "\(x)", to: &rex, terminator: sep)
        }
        let ned = rex.index(rex.endIndex, offsetBy: -sep.count)
        rex.replaceSubrange(ned..<rex.endIndex, with: "]")
        return rex
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
    func cyclic_accessor(_ idx: Int) -> Element {
        return self[idx % Int(count)]
    }
    
    func deepcopy() -> DataCon<Element> {
        let rex: DataCon<Element> = DataCon(capacity: self.count)
        rex.data.initialize(from: data, count: Int(self.count))
        //memcpy(data, rex.data, Int(self.count))
        return rex
    }
    
//    func deepcopy() -> DataCon<Element> {
//        let rex: DataCon<Element> = DataCon(capacity: self.count)
//        rex.data.withUnsafeMutableBytes { dst in
//            data.withUnsafeBytes { src in
//                dst.copyMemory(from: src)
//            }
//        }
//        return rex
//    }
    
    /// linspace init
    /// y = linspace(start, stop, step) generates n points.
    /// The spacing between the points is (x2-x1)/(n-1).
    init?(start: Element, stop: Element, n: UInt) {
        guard let d = try? (stop - start).safeDivide(n) as Element else {
            return nil
        }
        let N = Int(n)
        count = UInt(N)
        startIndex = 0
        data = UnsafeMutablePointer<Element>.allocate(capacity: N)
        //data.initialize(repeating: start, count: N)
        data[N - 1] = stop
        var x = start + d
        for idx in 1 ..< (N - 1) {
            data[idx] = x
            x += d
        }
    }
    /// allocate only
    /// Params -
    /// capacity: UInt
    init(capacity: UInt) {
        count = capacity
        data = UnsafeMutablePointer<Element>.allocate(capacity: Int(count))
        //data.initialize(repeating: rep, count: capacity)
        startIndex = 0
    }
    
    /// initialize by repeating given element and capacity
    init(repeating rep: Element, count capacity: Int) {
        //data = ContiguousArray<Element>(repeating: rep, count: capacity)
        count = UInt(capacity)
        data = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
        data.initialize(repeating: rep, count: capacity)
        startIndex = 0
    }
    
    // TODO: add deinit

    /// shallow copy ctor
    // TODO: I think this should only be handled by ref:
    // E.g.:
    // > A = DataCon([1, 2, 3])
    // > B = A // take the ref,
//    init(DataCon otro: DataCon<Element>, start: DataCon.Index?) {
//        data = otro.data
//        startIndex = start ?? otro.startIndex
//    }
    
    /// initialize from a given contiguous array and starting index in that array
    /// may be stupid idea, and should be that the mem-view always handles the offset
//    init(contiguousArray conarr: ContiguousArray<Element>, start: DataCon.Index = 0) {
//        data = conarr
//        startIndex = start
//    }
    
    /// array literal ctor allows following
    /// var dc: DataCon<Double> = [1, 2, 3]
    required convenience init(arrayLiteral elms: Element...) {
        self.init(elements: elms)
////        data = ContiguousArray<Element>(elements)
//        data.initialize(repeating: Element.Zero, count: elms.count)
//        for (ix, x) in elms.enumerated() {
//            data[ix] = x
//        }
//        startIndex = 0
    }

    init(elements elms: [Element]) {
        // data = ContiguousArray<Element>(elms)
        count = UInt(elms.count)
        let N: Int = elms.count
        data = UnsafeMutablePointer<Element>.allocate(capacity: N)
        for (ix, x) in elms.enumerated() {
            data[ix] = x
        }
        startIndex = 0
        
        // KILL:
        // still don't get Swift approach to pointers
//        elms.withUnsafeBytes { src in
//            data.initialize(from: src, count: N)
//        }
    }

    // TODO: "required convenience" seems slightly at cross purposes...?
    required init?(_ description: String) {
        let strings: [String] = description.removingDelimiters().components(separatedBy: String.VectorSeparators)
        let elms = strings.filter{(x: String)->Bool in return x.count > 0}.map{(x: String)->Element in return Element(x)!}

        // C&V from [Element] init ... "required convenience" approach drops core
        count = UInt(elms.count)
        let N: Int = elms.count
        data = UnsafeMutablePointer<Element>.allocate(capacity: N)
        for (ix, x) in elms.enumerated() {
            data[ix] = x
        }
        startIndex = 0
        // KILL:
//        self.init(elements: elements)  // seems to cause core dump
//        data = ContiguousArray<Element>(elements)
//        startIndex = 0
    }
    
    // Higher order functions -- maps, reduces, filters, etc. : behavior of these should reflect what is expected of the class
    // for example, *map* is removed to prevent *nil* elements in something passed to BLAS
    func makeIterator() -> DataConIterator<Element> {
        return DataConIterator(self)
    }

    func mapTo<ResultElement>(f: (DataCon.Element) -> ResultElement) -> DataCon<ResultElement> {
        // below, _let_ should be _var_ IMO, but SILGEN complains
        let rex: DataCon<ResultElement> = DataCon<ResultElement>(repeating: 0 as ResultElement, count: Int(count))
        for idx in startIndex ..< endIndex {
            rex.data[idx] = f(data[idx])
        }
        return rex
    }
    
    func compactMapTo<T: DaCoEl>(f: (Element) -> T?) -> DataCon<T>? {
        // TODO: this could be better
        var prerex = [T](repeating: T.Zero, count: Int(self.count))
        var idx: Int = 0
        for x in self {
            guard let y = f(x) else {
                continue
            }
            prerex[idx] = y
        }
        guard idx > 0 else {
            return nil
        }
        return DataCon<T>(elements: prerex)

//        let rex: DataCon<T> = DataCon<T>(repeating: T("0")!, count: count)
//        rex.data = ContiguousArray<T>(data.compactMap {f($0)})
//        guard rex.data.count > 0 else {
//            return nil
//        }
//        return rex
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

    
    /// matlab-like _diff_
    func diff() -> DataCon<Element> {
        // code in default behavior: override with dbl/flt version as desired
        let rex = DataCon.Zeros(UInt(self.count - 1))
        return rex
    }
    

    
    // static conveniences
    
    /// linspace
    /// y = linspace(start, stop, step) generates n points.
    /// The spacing between the points is (x2-x1)/(n-1).
    public static func Linspace(start: Element=0, stop: Element=1, n: UInt) -> DataCon {
        let rex:DataCon<Element> = DataCon(start: start, stop: stop, n: n)!
        return rex
    }
    
    public static func Ones(_ n: UInt) -> DataCon {
        let rex:DataCon<Element> = DataCon(repeating: Element.Identity, count: Int(n))
        return rex
    }
    public static func Zeros(_ n: UInt) -> DataCon {
        let rex:DataCon<Element> = DataCon(repeating: Element.Zero, count: Int(n))
        return rex
    }
    public static func Eye(_ n: UInt) -> DataCon {
        let rex:DataCon<Element> = DataCon(repeating: Element.Zero, count: Int(n * n))
        for idx in 0 ..< Int(n) {
            rex[DataCon<Element>.Index(idx)] = Element.Identity
        }
        return rex
    }
    public static func UnitVector(_ n: UInt, in_dimension N: UInt=3) -> DataCon? {
        guard n < N else {
            return nil
        }
        let rex:DataCon<Element> = DataCon.Zeros(N)
        rex[DataCon<Element>.Index(n)] = Element.Identity
        return rex
    }
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
