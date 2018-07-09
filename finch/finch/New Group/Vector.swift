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
    
    var description: String {
        get {
            return Matrix(datacon, memview).description
//            let beg = isRowVector ? "[[" : "["
//            let end = isRowVector ? "]]" : "]"
//            let begsep = isRowVector ? ", " : "["
//            let endsep = isRowVector ? "" : "]\n"
//            var rex = self.reduce(beg, {(rex: String, x: CDouble) -> String in
//                return "\(rex)\(begsep)\(x)\(endsep)"
//            })
//            if !isRowVector {
//                // back up one to erase newline...more efficient than tests in reducor
//                rex.removeLast(1)
//            }
//            rex += end
//            return rex
        }
    }
    
    // MARK: iterator
    func makeIterator() -> VectorIterator {
        return VectorIterator(self)
    }
    
//    /// copy the data from the given row into this instances *datacon*
//    func setrow(_ idx: UInt, _ v: Matrix, fromRow: UInt = 0) throws {
//        guard v.nrows == 1 && v.ncols == ncols else {
//            throw Exceptions.ShapeMismatch
//        }
//        let xoff = memview.data_index(idx, 0)
//        let xstr = memview.datastd.col_stride
//        let yoff = v.memview.data_index(fromRow, 0)
//        let ystr = v.memview.datastd.col_stride
//        datacon.set(from: v.datacon, n: v.ncols, xoffset: xoff, xstride: xstr, yoffset: yoff, ystride: ystr)
//    }
    
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
        guard idx <= vector.count else {
            return nil
        }
        defer { idx += 1 }
        return vector[idx]
    }
}
