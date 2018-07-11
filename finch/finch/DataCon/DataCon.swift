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
    Sequence,
    Codable,
    IDProtocol
//    where Element:Numeric
{
    // MARK: class members
    typealias Index = Int
    typealias Indices = Range<DataCon.Index>
    typealias ArrayLiteralElement = Element

    // MARK: enc/dec
    enum PropsKeys: String, CodingKey {
        case count
    }

    enum DataKeys: String, CodingKey {
        case data
    }

    public func encode(to encoder: Encoder) throws
    {
        var elems = encoder.unkeyedContainer()
        try elems.encode(count)
        for x in self {
            try elems.encode(x)
            //try (x as Encodable).encode(to: elems as! Encoder)
        }
    }
    
    required init(from decoder: Decoder) throws {
        var elems = try decoder.unkeyedContainer()
        count = try elems.decode(UInt.self)
        data = UnsafeMutablePointer<Element>.allocate(capacity: Int(count))
        for idx in 0..<Int(count) {
            try data[idx] = elems.decode(Element.self)
        }
    }
    
    // MARK: instance members
    let count: UInt
    let data: UnsafeMutablePointer<Element>
    
    let startIndex: DataCon.Index = 0
    var endIndex: DataCon.Index {
        guard count > 0 else {
            return 0 // bogus?
        }
        return DataCon.Index(count) - 1
    }

    // func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
    // func unkeyedContainer() -> UnkeyedEncodingContainer
    // func singleValueContainer() -> SingleValueEncodingContainer
    //var data: ContiguousArray<Element>
    

//    var count: DataCon.Index {
//        return DataCon.Index(data.count)
//    }
    
    var indices: Range<DataCon.Index> {
        return startIndex..<endIndex
    }

    func formIndex(before i: inout DataCon.Index) {
        i -= 1
    }
    
    func index(after i: DataCon.Index) -> DataCon.Index {
        return i + 1
    }
    
    // MARK: descriptors
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

    // MARK: operators
    
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

    // MARK: accessors
    
    /// accessor that treats the container as periodic
    func cyclic_accessor(_ idx: Int) -> Element {
        return self[idx % Int(count)]
    }

    // MARK: init/copy
    
    func deepcopy() -> DataCon<Element> {
        let rex: DataCon<Element> = DataCon(capacity: self.count)
        rex.data.initialize(from: data, count: Int(self.count))
        //memcpy(data, rex.data, Int(self.count))
        return rex
    }
    
    /// init with singly indexed function
    init(memview: VectorMemViewProtocol, f: (UInt) ->Element) {
        count = memview.required_capacity()
        data = UnsafeMutablePointer<Element>.allocate(capacity: Int(count))
        for idx in 0 ..< count {
            data[Int(memview.data_index(idx))] = f(idx)
        }
    }
    
    /// init with singly indexed function
    init(memview: MatrixMemViewProtocol, f: (UInt, UInt) ->Element) {
        count = memview.required_capacity()
        data = UnsafeMutablePointer<Element>.allocate(capacity: Int(count))
        for idx in 0 ..< memview.shape.nrows {
            for jdx in 0 ..< memview.shape.ncols {
                data[Int(memview.data_index(idx, jdx))] = f(idx, jdx)
            }
        }
    }

    /// linspace init
    /// y = linspace(start, stop, step) generates n points.
    /// The spacing between the points is (x2-x1)/(n-1).
    init?(start: Element, stop: Element, n: UInt) {
        guard let d = try? (stop - start).safeDivide(n - 1) as Element else {
            return nil
        }
        let N = Int(n)
        count = UInt(N)
        data = UnsafeMutablePointer<Element>.allocate(capacity: N)
        //data.initialize(repeating: start, count: N)
        data[0] = start
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
    }

    /// initialize from initialized unsafe pointer and capacity
    init(initializedPointer p: UnsafeMutablePointer<Element>, capacity: UInt) {
        count = capacity
        data = p
    }
    
    /// initialize by repeating given element and capacity
    init(repeating rep: Element, count capacity: Int) {
        //data = ContiguousArray<Element>(repeating: rep, count: capacity)
        count = UInt(capacity)
        data = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
        data.initialize(repeating: rep, count: capacity)
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
    }

    init(elements elms: [Element]) {
        // data = ContiguousArray<Element>(elms)
        count = UInt(elms.count)
        let N: Int = elms.count
        data = UnsafeMutablePointer<Element>.allocate(capacity: N)
        for (ix, x) in elms.enumerated() {
            data[ix] = x
        }
    }

    // TODO: "required convenience" seems slightly at cross purposes...?
    required convenience init?(_ description: String) {
        let strings: [String] = description.removingDelimiters().components(separatedBy: String.VectorSeparators)
        let elms = strings.filter{(x: String)->Bool in return x.count > 0}.map{(x: String)->Element in return Element(x)!}

        self.init(elements: elms)
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
            idx += 1
        }
        guard idx > 0 else {
            return nil
        }
        prerex = Array(prerex[..<idx])
        return DataCon<T>(elements: prerex)
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
    // do I need an "embedded" Eye? embedded as in the matrix represented is
    // within a larger container
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
        idx = 0
    }

    mutating func next() -> Element? {
        guard idx <= daco.endIndex else {
            return nil
        }
        defer { idx += 1 }
        return daco[idx]
    }

}
