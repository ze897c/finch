//
//  Matrix.swift
//  finch
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

// assumption here is Double, dense, no structural constraint
struct Matrix : MatrixProtocol {
    typealias Element = CDouble
    
    let memview: MatrixMemView
    let datacon: DataCon<CDouble>

    /// copy the data from the given row into this instances *datacon*
    func setrow(_ idx: UInt, _ v: Matrix, fromRow: UInt? = nil) throws {
        guard v.nrows == 1 && v.ncols == ncols else {
            throw Exceptions.ShapeMismatch
        }
        let xoff = memview.data_index(idx, 0)
        let xstr = memview.datastd.col_stride
        let yoff = v.memview.data_index(fromRow ?? idx, 0)
        let ystr = v.memview.datastd.col_stride
        datacon.set(from: v.datacon, n: v.ncols, xoffset: xoff, xstride: xstr, yoffset: yoff, ystride: ystr)
    }
    
    // TODO: setcol(_ idx: UInt, _ v: Matrix, fromCol: UInt = 0) throws {

    /// get the _idx_-th row, unless is 1-D row,
    /// in which case return _idx_-th col
    subscript(idx: UInt) -> Matrix? {
        get {
            guard idx < nrows else {
                return nil
            }
            return Matrix(datacon, memview.row(idx))
        }
        set {
//            if isRowVector {
//                
//            } else {
//                return Matrix(datacon, memview.row(idx))
//            }
        }
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
        memview = MatrixMemView(n)
        datacon = DataCon<CDouble>(capacity: n * n)
    }
    init(_ nrows: UInt, _ ncols: UInt) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<CDouble>(capacity: nrows * ncols)
    }
    
    /// ctors with shape and indexed function
    init(_ n: UInt, _ f: (UInt, UInt) -> CDouble) {
        memview = MatrixMemView(n)
        datacon = DataCon<CDouble>(capacity: n * n)
        map_inplace(f)
    }
    init(_ nrows: UInt, _ ncols: UInt, _ f: (UInt, UInt) -> CDouble) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<CDouble>(capacity: nrows * ncols)
        map_inplace(f)
    }
    
    init?(_ data: [[CDouble]]) {
        guard data.allSatisfy({(x: [CDouble]) in
            return x.count == data[0].count
        }) else {
            return nil
        }
        memview = MatrixMemView([UInt(data.count), UInt(data[0].count)])
        datacon = DataCon<CDouble>(capacity: memview.shape.nrows * memview.shape.ncols)
        // TODO: figure out when casts/coersions happen & do they burn time
        for idx in 0 ..< memview.shape.nrows {
            for jdx in 0 ..< memview.shape.ncols {
                let ddx = Int(memview.data_index(idx, jdx))
                datacon[ddx] = data[Int(idx)][Int(jdx)]
            }
        }
    }
    
    // MARK: map
    func map_inplace(_ f: (UInt, UInt) -> CDouble) {
        for idx in 0 ..< nrows {
            for jdx in 0 ..< ncols {
                let ddx: Int = Int(memview.data_index(idx, jdx))
                datacon[ddx] = f(idx, jdx)
            }
        }
    }

    // TODO : write one that maps to a _Slice_:
    // should dispatch through the *memview*
//    func map_inplace(_ f: (CDouble, UInt, UInt) -> CDouble, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil) {
//        datacon.map_inplace(f, n: n, xstride: xstride, xoffset: xoffset)
//    }
//
//    func map(_ f: (CDouble, UInt, UInt) -> CDouble) -> Matrix {
//        let rex = Matrix(self)
//        rex.map_inplace(f)
//        return rex
//    }
    
    func map_inplace(_ f: (CDouble) -> CDouble, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil) {
        datacon.map_inplace(f, n: n, xstride: xstride, xoffset: xoffset)
    }

    func map(_ f: (CDouble) -> CDouble) -> Matrix {
        let rex = Matrix(self)
        rex.map_inplace(f)
        return rex
    }

    // MARK: static ctors
    
    /// identity *Matrix* of size _n_
    static func Eye(_ n: UInt) -> Matrix {
        let rex = Matrix.Zeros(n)
        for idx in 0 ..< n {
            rex.datacon[DataCon<Element>.Index(idx * n)] = 1.0
        }
        return rex
    }

    /// square *Matrix* of size _n_ of all zeros
    static func Zeros(_ n: UInt) -> Matrix {
        let dc = DataCon<CDouble>.BLASConstant(0.0, n * n)
        let rex = Matrix(dc, MatrixMemView(n))
        return rex
    }
    
    /// square *Matrix* of size _m x n_ of all zeros
    static func Zeros(_ m: UInt, _ n: UInt) -> Matrix {
        let dc = DataCon<CDouble>.BLASConstant(0.0, m * n)
        let rex = Matrix(dc, MatrixMemView([m, n]))
        return rex
    }
}
