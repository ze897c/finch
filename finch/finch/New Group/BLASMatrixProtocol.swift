//
//  BLASMatrixProtocol.swift
//  finch
//
//  Created by Matthew Patterson on 7/4/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

protocol BLASMatrixProtocol : MatrixProtocol {
    typealias Element = CDouble
    
    var memview: MatrixMemView {get}
    var datacon: DataCon<CDouble> {get}

    init(_ data_con: DataCon<CDouble>, _ mem_view: MatrixMemView)

    /// {
    /// init from swift data
    /// return nil if ragged
    init?(_ x: [[CDouble]])
    /// }
    
    // MARK: static ctors
    

}

extension BLASMatrixProtocol {
    
    // MARK: map
    func map_inplace(_ f: (UInt, UInt) -> CDouble) {
        for idx in 0 ..< nrows {
            for jdx in 0 ..< ncols {
                let ddx: Int = Int(memview.data_index(idx, jdx))
                datacon[ddx] = f(idx, jdx)
            }
        }
    }
    
    // MARK: set row/col/etc.
    
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
    
    // MARK: safe gettors/settors
    
    // TODO: func getrow(_ idx: UInt,) throws {
    // TODO: func getcol(_ idx: UInt,) throws {
    // TODO: func getelem(_ idx: UInt, _ jdx: UInt) throws {
    
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

    // TODO: setelem(_ idx: UInt, _ jdx: UInt, _ CDouble val) throws {
    // TODO: setelem(_ idx: UInt, _ jdx: UInt, fromMatrix MatrixProtocol A) throws {
}
