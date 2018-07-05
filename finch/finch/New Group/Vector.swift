//
//  Vector.swift
//  finch
//
//  Created by Matthew Patterson on 7/3/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
// assumption here is Double, dense, no structural constraint
struct Vector : BLASMatrixProtocol {

    typealias Element = CDouble
    
    let memview: MatrixMemView
    let datacon: DataCon<CDouble>

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
    subscript(idx: UInt) -> Element {
        get {
            if isRowVector {
                return datacon[DataCon<Element>.Index(memview.data_index(idx, 0))]
            } else {
                return datacon[DataCon<Element>.Index(memview.data_index(0, idx))]
            }
        }
        set {
            if isRowVector {
                datacon[DataCon<Element>.Index(memview.data_index(idx, 0))] = CDouble(newValue)
            } else {
                datacon[DataCon<Element>.Index(memview.data_index(0, idx))] = CDouble(newValue)
            }
        }
    }
    
    // MARK: inits

    init(_ data_con: DataCon<CDouble>, _ mem_view: MatrixMemView) {
        datacon = data_con
        memview = mem_view
    }
    /// {
    /// simple ctor: when only length is perscribed
    /// defaults to column vector
    init(_ n: UInt) {
        memview = MatrixMemView([UInt(1), n])
        datacon = DataCon<CDouble>(capacity: n)
    }
    init(nrows n: UInt) {
        memview = MatrixMemView([n, UInt(1)])
        datacon = DataCon<CDouble>(capacity: n)
    }
    /// }

    /// {
    /// ctors with shape and indexed function
    init(_ n: UInt, _ f: (UInt) -> CDouble) {
        memview = MatrixMemView([n, 1])
        datacon = DataCon<CDouble>(capacity: n * n)
        map_inplace(f)
    }
    init(nrows n: UInt, _ f: (UInt) -> CDouble) {
        memview = MatrixMemView( [1, n])
        datacon = DataCon<CDouble>(capacity: n * n)
        map_inplace(f)
    }
    /// }
    
    /// {
    /// construct with size and constant *CDouble*
    init(_ n: UInt, doubleValue x: CDouble) {
        memview = MatrixMemView([n, 1])
        datacon = DataCon<CDouble>(repeating: x, count: Int(n))
    }
    init(nrows n: UInt, doubleValue x: CDouble) {
        memview = MatrixMemView([1, n])
        datacon = DataCon<CDouble>(repeating: x, count: Int(n))
    }
    // essentially deleting this ctor
    init?(_ nrows: UInt, _ ncols: UInt, doubleValue x: CDouble) {
        return nil
    }
    /// }

    /// {
    /// construct from Swift double array of *CDouble*
    init?(_ data: [[CDouble]]) {
        guard data.allSatisfy({(x: [CDouble]) in
            return x.count == 1
        }) else {
            return nil
        }
        memview = MatrixMemView([UInt(data.count), UInt(1)])
        datacon = DataCon<CDouble>(capacity: memview.shape.nrows * memview.shape.ncols)
        setfromCDoubleData(data)
    }
    init?(rowData data: [[CDouble]]) {
        guard data.count == 1 else {
            return nil
        }
        memview = MatrixMemView([ UInt(1), UInt(data.count)])
        datacon = DataCon<CDouble>(capacity: memview.shape.nrows * memview.shape.ncols)
        setfromCDoubleData(data)
    }
    /// }
    
    /// copy constructor
    /// uses reference to underlying storage
    init(_ x: BLASMatrixProtocol) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon
    }

    /// deepcopy ctor
    init(deepCopyFrom x: BLASMatrixProtocol) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon.deepcopy()
    }
    
    // {
    // _remove_ inits that don't make strict sense for *Vector*
    init?(_ nrows: UInt, _ ncols: UInt) {
        return nil
    }
    init?(_ n: UInt, _ f: (UInt, UInt) -> CDouble) {
        return nil
    }
    init?(_ nrows: UInt, _ ncols: UInt, _ f: (UInt, UInt) -> CDouble) {
        return nil
    }
    // }

    // MARK: map
    
//    func map(_ f: (CDouble) -> CDouble) -> Vector {
//        let rex = Matrix(self)
//        rex.map_inplace(f)
//        return rex
//    }
    
    // MARK: static ctors
    
    /// identity *Matrix* of size _n_
    static func E(_ n: UInt) -> Matrix {
        let rex = Matrix.Zeros(n)
        for idx in 0 ..< n {
            rex.datacon[DataCon<Element>.Index(idx * n)] = 1.0
        }
        return rex
    }
    
    /// square *Matrix* of size _n_ of all zeros
    static func Zeros(_ n: UInt) -> Matrix {
        return Matrix(DataCon<CDouble>.BLASConstant(0.0, n), MatrixMemView([n, 1]))
    }
    
    /// square *Matrix* of size _m x n_ of all zeros
    static func Zeros(nrows n: UInt) -> Matrix {
        return Matrix(DataCon<CDouble>.BLASConstant(0.0, n), MatrixMemView([1, n]))
    }
}
