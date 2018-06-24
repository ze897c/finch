//
//  MemViewProtocols.swift
//  finch
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

protocol VectorMemViewProtocol {
    var shape: (UInt) {get}
    var dataoff: UInt {get}
    var datastd: (UInt) {get}
    func data_index(_ idx: UInt) -> UInt
    func shaped_index(idx: UInt) -> UInt
    func required_capacity() -> UInt
}

extension VectorMemViewProtocol {
    /// given the index from the *Vector* POV
    /// return the index in the data container POV
    func data_index(_ idx: UInt) -> UInt {
        return dataoff + datastd * idx
    }
    /// given: index from the data container POV,
    /// return the index in the *Vector* POV
    func shaped_index(_ idx: UInt) -> UInt {
        return 0
        //return dataoff + datastd * idx
    }
    /// return the number of elements this view requires
    /// including offset & striding
    func required_capacity() -> UInt {
        return dataoff + shape * datastd
    }
}

protocol MatrixMemViewProtocol {
    var shape: (nrows: UInt, ncols: UInt) {get}
    var dataoff: UInt {get}
    var datastd: (row_stride: UInt, col_stride: UInt) {get}
    func data_index(_ idx: UInt, _ jdx: UInt) -> UInt
    func shaped_index(idx: UInt) -> UInt
    func required_capacity() -> UInt
}

extension MatrixMemViewProtocol {
    /// given the index from the *Vector* POV
    /// return the index in the data container POV
    func data_index(_ idx: UInt, _ jdx: UInt) -> UInt {
        return dataoff + datastd.row_stride * idx + datastd.col_stride * jdx
    }
    func shaped_index(idx: UInt) -> UInt {
        return 0
    }
    /// return the number of elements this view requires
    /// including offset & striding
    func required_capacity() -> UInt {
        return data_index(shape.nrows - 1, shape.ncols - 1) + 1
    }
}

struct MatrixMemView: MatrixMemViewProtocol {
    let shape: (nrows: UInt, ncols: UInt)
    let dataoff: UInt
    let datastd: (row_stride: UInt, col_stride: UInt)
    
    init(sq_size: UInt) {
        shape = (sq_size, sq_size)
        dataoff = 0
        datastd = (1, sq_size)
    }
    init(_ ns: [UInt]) {
        shape = (ns[0], ns[1])
        dataoff = 0
        datastd = (1, ns[0])
    }
}

protocol Tensor3MemViewProtocol {
    var shape: (nrows: UInt, ncols: UInt, nrnks: UInt) {get}
    var dataoff: UInt {get}
    var datastd: (row_stride: UInt, col_stride: UInt, rnk_stride: UInt) {get}
}

//struct VectorMemView: VectorMemViewProtocol {
//    typealias Element = CDouble
//    var datacon: DataCon<E>
//    subscript(_ idx:UInt) -> Element {
//        get{
//            return datacon[Int(idx)]
//        }
//        set {
//            datacon[Int(idx)] = newValue
//        }
//    }
//}
