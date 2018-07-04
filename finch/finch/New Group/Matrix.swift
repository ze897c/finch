//
//  Matrix.swift
//  finch
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

// assumption here is Double, dense, no structural constraint
struct Matrix : BLASMatrixProtocol {
    typealias Element = CDouble
    
    let memview: MatrixMemView
    let datacon: DataCon<CDouble>

    /// map the function, returning new
    func map(_ f: (CDouble) -> CDouble) -> Matrix {
        let rex = Matrix(deepCopyFrom: self)
        rex.map_inplace(f)
        return rex
    }

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
    init(deepCopyFrom x: BLASMatrixProtocol) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon.deepcopy()
    }
    
//    init(deepCopyFrom x: Matrix) {
//        memview = MatrixMemView(x.memview)
//        datacon = x.datacon.deepcopy()
//    }
    
    /// normal swift assignment gives shallow...or does it
    init(_ x: BLASMatrixProtocol) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon
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
