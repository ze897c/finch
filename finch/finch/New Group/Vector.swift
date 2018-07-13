//
//  Vector.swift
//  finch
//
//  Created by Matthew Patterson on 7/3/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

// assumption here is Double, dense, no structural constraint
struct Vector : BLASMatrixProtocol, Sequence {

    typealias DataElement = CDouble
    typealias Element = CDouble
    
    let memview: MatrixMemView
    let datacon: DataCon<DataElement>
    
    var shape: (nrows: UInt, ncols: UInt) {
        return memview.shape
    }
    
    var count: UInt {
        get {
            return shape.nrows * shape.ncols
        }
    }
    
    var offset: UInt {
        get {
            return memview.dataoff
        }
    }
    
    var stride: UInt {
        get {
            return isRowVector ? memview.col_stride : memview.row_stride
        }
    }

    var description: String {
        get {
            return asMatrix.description
        }
    }
    
    var asMatrix: Matrix {
        get {
            return Matrix(datacon, memview)
        }
    }
    
    // MARK: idaminmax(s)
    func imaxmag() -> UInt {
        return datacon.imaxmag(count, offset, stride)
    }

    // MARK: manip

    /// swap vectors in place
    func swap(_ b: Vector) throws {
        guard count == b.count else {
            throw Exceptions.ShapeMismatch
        }
        datacon.swap(b.datacon, count, offset, stride, b.offset, b.stride)
    }
    
    // TODO: dasum
    
    // MARK: math/algebra
    func distance(_ v: Vector) -> CDouble? {
        guard count == v.count else {
            return nil
        }
        return 0 // TODO:
    }
    
    /// a * x + b * y -> x
    /// UNSAFE
    func axpby_inplace(_ y: Vector, _ a: CDouble, _ b: CDouble) {
        datacon.axpby_inplace(a, y.datacon, b, n: count, xstride: stride, xoffset: offset, ystride: y.stride, yoffset: y.offset)
    }
    
    /// unsafe
    func add(_ b: Vector) -> Vector {
        return self // TODO:
    }

    func sub(_ b: Vector) -> Vector {
        return self // TODO:
    }

    func add(_ b: CDouble) -> Vector {
        return self // TODO:
    }

    func sub(_ b: CDouble) -> Vector {
        return self // TODO:
    }

    func mul(_ b: CDouble) -> Vector {
        let rex = Vector(datacon.deepcopy(), memview)
        rex.mul_inplace(b)
        return rex
    }

    mutating func add_inplace(_ b: Vector) {
        //return a // TODO:
    }

    mutating func sub_inplace(_ b: Vector) {
        //return a // TODO:
    }

    mutating func add_inplace(_ b: [CDouble]) {
        for idx in 0..<count {
            self[idx] += b[Int(idx)]
        }
    }
    
    mutating func sub_inplace(_ b: [CDouble]) {
        for idx in 0..<count {
            self[idx] -= b[Int(idx)]
        }
    }
    
    mutating func add_inplace(_ b: CDouble) {
        for idx in 0..<count {
            self[idx] += b
        }
    }

    mutating func sub_inplace(_ b: CDouble) {
        for idx in 0..<count {
            self[idx] -= b
        }
    }

    /// x * y -> x
    /// where _x_ is the instance & operation is elementwise
    mutating func mul_inplace(_ y: Vector) {
        datacon.mul_inplace(y.datacon, n: count, xstride: stride, xoffset: offset, ystride: y.stride, yoffset: y.offset)
    }

    /// x * b -> x
    /// where _x_ is the instance
    func mul_inplace(_ b: CDouble) {
        datacon.scale_inplace(b, n: count, stride: stride, offset: offset)
    }

    static func +(_ a: Vector, _ b: Vector) -> Vector? {
        guard a.count == b.count else {
            return nil
        }
        return a.add(b)
    }
    
    static func -(_ a: Vector, _ b: Vector) -> Vector? {
        guard a.count == b.count else {
            return nil
        }
        return a.sub(b)
    }
    
    static func +=(_ a: inout Vector, _ b: CDouble) {
        a.add_inplace(b)
    }

    static func -=(_ a: inout Vector, _ b: CDouble) {
        a.sub_inplace(b)
    }

    static func +=(_ a: inout Vector, _ b: [CDouble]) throws {
        guard a.count == b.count else {
            throw Exceptions.ShapeMismatch
        }
        a.add_inplace(b)
    }
    
    static func -=(_ a: inout Vector, _ b: [CDouble]) throws {
        guard a.count == b.count else {
            throw Exceptions.ShapeMismatch
        }
        a.sub_inplace(b)
    }
    
    static func *(_ a: Vector, _ b: CDouble) -> Vector {
        return a.mul(b)
    }
    static func *(_ b: CDouble, _ a: Vector) -> Vector {
        return a.mul(b)
    }
    static func *=(_ a: inout Vector, _ b: CDouble) {
        a.mul_inplace(b)
    }
    
    static func +=(_ a: inout Vector, _ b: Vector) throws {
        guard a.count == b.count else {
            throw Exceptions.ShapeMismatch
        }
        a.add_inplace(b)
    }
    
    static func -=(_ a: inout Vector, _ b: Vector) throws {
        guard a.count == b.count else {
            throw Exceptions.ShapeMismatch
        }
        a.sub_inplace(b)
    }

    func dot(_ v: Vector) throws -> CDouble {
        guard count == v.count else {
            throw Exceptions.ShapeMismatch
        }
        return inner_product(v)
    }
    
    func inner_product(_ v: Vector) -> CDouble {
        return 0 // TODO:
    }
    
    func outer_product(_ v: Vector) -> Matrix? {
        guard count == v.count else {
            return nil
        }
        return Matrix(1, 1) // TODO:
    }

    // MARK: iterator
    func makeIterator() -> VectorIterator {
        return VectorIterator(self)
    }

    /// get the _idx_-th row, unless is 1-D row,
    /// in which case return _idx_-th col
    /// NOTE: unsafe...
    subscript(idx: UInt) -> DataElement {
        get {
            if isRowVector {
                return datacon[DataCon<DataElement>.Index(memview.data_index(0, idx))]
            } else {
                return datacon[DataCon<DataElement>.Index(memview.data_index(idx, 0))]
            }
        }
        set {
            if isRowVector {
                datacon[DataCon<DataElement>.Index(memview.data_index(0, idx))] = DataElement(newValue)
            } else {
                datacon[DataCon<DataElement>.Index(memview.data_index(idx, 0))] = DataElement(newValue)
            }
        }
    }
    
    // MARK: inits

    init(_ data_con: DataCon<DataElement>, _ mem_view: MatrixMemView) {
        datacon = data_con
        memview = mem_view
    }
    /// {
    /// simple ctor: when only length is perscribed
    /// defaults to column vector
    init(_ n: UInt) {
        memview = MatrixMemView([UInt(1), n])
        datacon = DataCon<DataElement>(capacity: n)
    }
    init(nrows n: UInt) {
        memview = MatrixMemView([n, UInt(1)])
        datacon = DataCon<DataElement>(capacity: n)
    }
    /// }

    /// {
    /// ctors with shape and indexed function
    init(_ n: UInt, _ f: (UInt) -> DataElement) {
        memview = MatrixMemView([n, 1])
        datacon = DataCon<DataElement>(capacity: n * n)
        map_inplace(f)
    }
    init(nrows n: UInt, _ f: (UInt) -> DataElement) {
        memview = MatrixMemView( [1, n])
        datacon = DataCon<DataElement>(capacity: n * n)
        map_inplace(f)
    }
    /// }
    
    /// {
    /// construct with size and constant *DataElement*
    init(_ n: UInt, doubleValue x: DataElement) {
        memview = MatrixMemView([n, 1])
        datacon = DataCon<DataElement>(repeating: x, count: Int(n))
    }
    init(nrows n: UInt, doubleValue x: DataElement) {
        memview = MatrixMemView([1, n])
        datacon = DataCon<DataElement>(repeating: x, count: Int(n))
    }
    // essentially deleting this ctor
    init?(_ nrows: UInt, _ ncols: UInt, doubleValue x: DataElement) {
        return nil
    }
    /// }

    /// {
    /// construct from Swift double array of *DataElement*
    init(_ data: [DataElement]) {
        memview = MatrixMemView([UInt(data.count), UInt(1)])
        datacon = DataCon<DataElement>(capacity: memview.shape.nrows * memview.shape.ncols)
        setfromData(data)
    }
    
    init?(_ data: [[DataElement]]) {
        guard data.count == 1 || data.allSatisfy({(x: [DataElement]) in
            return x.count == 1
        }) else {
            return nil
        }
        memview = data.count == 1 ? MatrixMemView([UInt(1), UInt(data[0].count)]) : MatrixMemView([UInt(data.count), UInt(1)])
        datacon = DataCon<DataElement>(capacity: memview.required_capacity())
        setfromData(data)
    }
    init?(rowData data: [[DataElement]]) {
        guard data.count == 1 else {
            return nil
        }
        memview = MatrixMemView([ UInt(1), UInt(data.count)])
        datacon = DataCon<DataElement>(capacity: memview.shape.nrows * memview.shape.ncols)
        setfromData(data)
    }
    /// }
    
    /// copy constructor
    /// uses reference to underlying storage
    init(_ x: Vector) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon
    }

    /// deepcopy ctor
    init(deepCopyFrom x: Vector) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon.deepcopy()
    }
    
    // {
    // _remove_ inits that don't make strict sense for *Vector*
    init?(_ nrows: UInt, _ ncols: UInt) {
        return nil
    }
    init?(_ n: UInt, _ f: (UInt, UInt) -> DataElement) {
        return nil
    }
    init?(_ nrows: UInt, _ ncols: UInt, _ f: (UInt, UInt) -> DataElement) {
        return nil
    }
    // }

    // MARK: map
    
//    func map(_ f: (DataElement) -> DataElement) -> Vector {
//        let rex = Matrix(self)
//        rex.map_inplace(f)
//        return rex
//    }
    
    // MARK: modify
    func transpose() -> Vector {
        return Vector(datacon, memview.transpose())
    }
    // TODO: ...
    func transpose_inplace() {
        //return Matrix(datacon, memview.transpose())
    }
    
    // MARK: static ctors
    
    /// identity *Matrix* of size _n_
    static func E(_ n: UInt) -> Matrix {
        let rex = Matrix.Zeros(n)
        for idx in 0 ..< n {
            rex.datacon[DataCon<DataElement>.Index(idx * n)] = 1.0
        }
        return rex
    }
    
    /// square *Matrix* of size _n_ of all zeros
    static func Zeros(_ n: UInt) -> Matrix {
        return Matrix(DataCon<DataElement>.BLASConstant(0.0, n), MatrixMemView([n, 1]))
    }
    
    /// square *Matrix* of size _m x n_ of all zeros
    static func Zeros(nrows n: UInt) -> Matrix {
        return Matrix(DataCon<DataElement>.BLASConstant(0.0, n), MatrixMemView([1, n]))
    }
}

struct VectorIterator
    :
    IteratorProtocol
{
    let vector: Vector
    var idx: UInt
    
    init(_ v: Vector) {
        vector = v
        idx = 0
    }
    
    mutating func next() -> Vector.DataElement? {
        guard idx < vector.count else {
            return nil
        }
        defer { idx += 1 }
        return vector[idx]
    }
}

