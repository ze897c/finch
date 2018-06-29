//
//  Matrix.swift
//  finch
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

// assumption here is Double, dense, no structural constraint
struct Matrix {
    typealias Element = CDouble
    
    let memview: MatrixMemView
    let datacon: DataCon<CDouble>

    var shape: (nrows: UInt, ncols: UInt) {
        get {
            return memview.shape
        }
    }
    var nrows: UInt {
        get {
            return memview.shape.nrows
        }
    }
    var ncols: UInt {
        get {
            return memview.shape.ncols
        }
    }

    var isRowVector: Bool {
        get {
            return memview.shape.nrows == 1
        }
    }
    var isColVector: Bool {
        get {
            return memview.shape.ncols == 1
        }
    }
    /// copy the data from the given row into this instances *datacon*
    func setrow(_ idx: UInt, _ v: Matrix, fromRow: UInt = 0) throws {
        guard v.nrows == 1 && v.ncols == ncols else {
            throw Exceptions.ShapeMismatch
        }
        let xoff = memview.data_index(idx, 0)
        let xstr = memview.datastd.col_stride
        let yoff = v.memview.data_index(fromRow, 0)
        let ystr = v.memview.datastd.col_stride
        datacon.set(from: v.datacon, n: v.ncols, xoffset: xoff, xstride: xstr, yoffset: yoff, ystride: ystr)
        
    }
    
    /// get the _idx_-th row, unless is 1-D row,
    // in which case return element
    subscript(idx: UInt) -> Matrix? {
        get{
            guard idx < nrows else {
                return nil
            }
            return Matrix(datacon, memview.row(idx))
        }
//        set(x: Matrix) {
//
//        }
    }
    
    // MARK: inits
    
    /// deepcopy ctor
    /// normal swift assignment gives shallow
    init(_ x: Matrix) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon.deepcopy()
    }
    init(_ data_con: DataCon<CDouble>, _ mem_view: MatrixMemView) {
        datacon = data_con
        memview = mem_view
    }
    /// simple ctors when only shape is perscribed
    init(_ n: UInt) {
        memview = MatrixMemView(sq_size: n)
        datacon = DataCon<CDouble>(capacity: n * n)
    }
    init(_ nrows: UInt, _ ncols: UInt) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<CDouble>(capacity: nrows * ncols)
    }
}
