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
    let datacon: DataCon<Element>

    /// map the function, returning new
    func map(_ f: (Element) -> Element) -> Matrix {
        let rex = Matrix(deepCopyFrom: self)
        rex.map_inplace(f)
        return rex
    }

    /// get/set the _idx_-th row as a *Vector*
    /// get returns *nil* when data unavailable
    /// set is just unsafe
    subscript(idx: UInt) -> Vector? {
        get {
            guard idx < nrows else {
                return nil
            }
            return Vector(datacon, memview.row(idx))
        }
        set (x) {
            let v = x!
            let fromOffset = v.memview.dataoff
            let fromStride = v.isRowVector ? v.memview.datastd.col_stride : v.memview.datastd.row_stride
            let toOffset = memview.dataoff
            let toStride = memview.datastd.col_stride
            self.datacon.set(from: v.datacon, n: fromOffset, xoffset: fromStride, xstride: toOffset, yoffset: toStride)
            // TODO - add *throws* ??
        }
    }
    
    // MARK: inits
    
    /// deepcopy ctor
    init(deepCopyFrom x: Matrix) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon.deepcopy()
    }

    /// normal swift assignment gives shallow...or does it
    init(_ x: Matrix) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon
    }
    init(_ data_con: DataCon<Element>, _ mem_view: MatrixMemView) {
        datacon = data_con
        memview = mem_view
    }

    /// simple ctors when only shape is perscribed
    init(_ n: UInt) {
        memview = MatrixMemView(n)
        datacon = DataCon<Element>(capacity: n * n)
    }
    init(_ nrows: UInt, _ ncols: UInt) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<Element>(capacity: nrows * ncols)
    }
    
    /// ctors with shape and indexed function
    init(_ n: UInt, _ f: (UInt, UInt) -> Element) {
        memview = MatrixMemView(n)
        datacon = DataCon<Element>(capacity: n * n)
        map_inplace(f)
    }
    init(_ nrows: UInt, _ ncols: UInt, _ f: (UInt, UInt) -> Element) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<Element>(capacity: nrows * ncols)
        map_inplace(f)
    }
    
    /// ctors with shape and fixed value
    init(_ n: UInt, doubleValue x: Element) {
        memview = MatrixMemView(n)
        datacon = DataCon<Element>(repeating: x, count: Int(n * n))
    }
    init(_ nrows: UInt, _ ncols: UInt, doubleValue x: Element) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<Element>(repeating: x, count: Int(nrows * ncols))
    }
    
    init?(_ data: [[Element]]) {
        guard data.allSatisfy({(x: [Element]) in
            return x.count == data[0].count
        }) else {
            return nil
        }
        memview = MatrixMemView([UInt(data.count), UInt(data[0].count)])
        datacon = DataCon<Element>(capacity: memview.shape.nrows * memview.shape.ncols)
        // TODO: figure out when casts/coersions happen & do they burn time
        for idx in 0 ..< memview.shape.nrows {
            for jdx in 0 ..< memview.shape.ncols {
                let ddx = Int(memview.data_index(idx, jdx))
                datacon[ddx] = data[Int(idx)][Int(jdx)]
            }
        }
    }
    
    // MARK: modify
    func transpose() -> Matrix {
        return Matrix(datacon, memview.transpose())
    }
    // TODO: ...
    func transpose_inplace() -> Matrix {
        return Matrix(datacon, memview.transpose())
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
        let dc = DataCon<Element>.BLASConstant(0.0, n * n)
        let rex = Matrix(dc, MatrixMemView(n))
        return rex
    }
    
    /// square *Matrix* of size _m x n_ of all zeros
    static func Zeros(_ m: UInt, _ n: UInt) -> Matrix {
        let dc = DataCon<Element>.BLASConstant(0.0, m * n)
        let rex = Matrix(dc, MatrixMemView([m, n]))
        return rex
    }
}
