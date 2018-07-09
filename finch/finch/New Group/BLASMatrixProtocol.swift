//
//  BLASMatrixProtocol.swift
//  finch
//
//  Created by Matthew Patterson on 7/4/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

protocol BLASMatrixProtocol : MatrixProtocol {
    //typealias Element = Element
    associatedtype Element: DaCoEl

    var memview: MatrixMemView {get}
    var datacon: DataCon<Element> {get}

    /// full boat ctor
    init(_ data_con: DataCon<Element>, _ mem_view: MatrixMemView)
    
    /// {
    /// init from swift data
    /// return nil if ragged
    init?(_ x: [[Element]])
    /// }
    
    /// {
    /// simple ctors when only shape is perscribed
    init(_ n: UInt)
    init?(_ nrows: UInt, _ ncols: UInt) // is failable to still be valid for *Vector*
    /// }

    /// {
    /// ctors with shape and indexed function
    // failable to still be valid for *Vector*
    init?(_ n: UInt, _ f: (UInt, UInt) -> Element)
    init?(_ nrows: UInt, _ ncols: UInt, _ f: (UInt, UInt) -> Element)
    /// }

    /// {
    /// ctors with shape and fixed value
    // failable to still be valid for *Vector*
    init(_ n: UInt, doubleValue x: Element)
    init?(_ nrows: UInt, _ ncols: UInt, doubleValue x: Element)
    /// }
}

extension BLASMatrixProtocol where Element == CDouble {
    
//    /// shallow ctor
//    init(_ x: BLASMatrixProtocol)
//    /// deep ctor
//    init(deepCopyFrom x: BLASMatrixProtocol)
    
    // MARK: map
    func map_inplace(_ f: (UInt, UInt) -> Element) {
        for idx in 0 ..< nrows {
            for jdx in 0 ..< ncols {
                let ddx: Int = Int(memview.data_index(idx, jdx))
                datacon[ddx] = f(idx, jdx)
            }
        }
    }
    func map_inplace(_ f: (UInt) -> Element) {
        for idx in 0 ..< nrows {
            for jdx in 0 ..< ncols {
                let ddx: Int = Int(memview.data_index(idx, jdx))
                datacon[ddx] = f(idx)
            }
        }
    }

    // MARK: set row/col/etc.
    
    // TODO : write one that maps to a _Slice_:
    // should dispatch through the *memview*
    //    func map_inplace(_ f: (Element, UInt, UInt) -> Element, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil) {
    //        datacon.map_inplace(f, n: n, xstride: xstride, xoffset: xoffset)
    //    }
    //
    //    func map(_ f: (Element, UInt, UInt) -> Element) -> Matrix {
    //        let rex = Matrix(self)
    //        rex.map_inplace(f)
    //        return rex
    //    }
    
    func map_inplace(_ f: (Element) -> Element, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil) {
        datacon.flatmap_inplace(f, n: n, xstride: xstride, xoffset: xoffset)
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

    // TODO: setelem(_ idx: UInt, _ jdx: UInt, _ Element val) throws {
    // TODO: setelem(_ idx: UInt, _ jdx: UInt, fromMatrix MatrixProtocol A) throws {
    
    func setfromElementData(_ data: [CDouble]) {
        // TODO: figure out when casts/coersions happen & do they burn time
        for idx in 0 ..< memview.shape.nrows {
            for jdx in 0 ..< memview.shape.ncols {
                let ddx = Int(memview.data_index(idx, jdx))
                datacon[ddx] = data[ddx]
            }
        }
    }
    
    func setfromElementData(_ data: [[CDouble]]) {
        // TODO: figure out when casts/coersions happen & do they burn time
        for idx in 0 ..< memview.shape.nrows {
            for jdx in 0 ..< memview.shape.ncols {
                let ddx = Int(memview.data_index(idx, jdx))
                datacon[ddx] = data[Int(idx)][Int(jdx)]
            }
        }
    }
    
    var data_mtble_ptr: UnsafeMutablePointer<CDouble> {
        get {
            return datacon.data + Int(memview.dataoff)
        }
    }
    
    var data_const_ptr: UnsafePointer<CDouble> {
        get {
            return UnsafePointer<CDouble>(datacon.data + Int(memview.dataoff))
        }
    }

}
