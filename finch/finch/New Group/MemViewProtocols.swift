//
//  MemViewProtocols.swift
//  finch
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

protocol VectorMemViewProtocol {
    var shape: UInt {get}
    var dataoff: UInt {get}
    var datastd: UInt {get}
    func data_index(_ idx: UInt) -> UInt
    func shaped_index(_ idx: UInt) -> UInt
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

enum MatrixMemViewCodingKeys: String, CodingKey {
    case nrows, ncols, dataoff, row_stride, col_stride
}

protocol MatrixMemViewProtocol {
    var shape: (nrows: UInt, ncols: UInt) {get}
    var dataoff: UInt {get}
    var datastd: (row_stride: UInt, col_stride: UInt) {get}
    var count: UInt {get}
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
    
    var count: UInt {
        get {
            return shape.nrows * shape.ncols
        }
    }
}


// assume non-symetric, dense, _etc_
// and name symetric, sparse, _etc_ appropriately
struct MatrixMemView: MatrixMemViewProtocol, Codable {
    

    // func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
    // func unkeyedContainer() -> UnkeyedEncodingContainer
    // func singleValueContainer() -> SingleValueEncodingContainer
    
    
    // MARK: enc/dec
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: MatrixMemViewCodingKeys.self)
        try container.encode(shape.nrows, forKey: .nrows)
        try container.encode(shape.ncols, forKey: .ncols)
        try container.encode(dataoff, forKey: .dataoff)
        try container.encode(datastd.row_stride, forKey: .row_stride)
        try container.encode(datastd.col_stride, forKey: .col_stride)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MatrixMemViewCodingKeys.self)
        shape.nrows = try container.decode(UInt.self, forKey: .nrows)
        shape.ncols = try container.decode(UInt.self, forKey: .ncols)
        dataoff = try container.decode(UInt.self, forKey: .dataoff)
        datastd.row_stride = try container.decode(UInt.self, forKey: .row_stride)
        datastd.col_stride = try container.decode(UInt.self, forKey: .col_stride)
    }
    
    let shape: (nrows: UInt, ncols: UInt)
    let dataoff: UInt
    let datastd: (row_stride: UInt, col_stride: UInt)
    
    var row_stride: UInt {
        get {
            return datastd.row_stride
        }
    }

    var col_stride: UInt {
        get {
            return datastd.col_stride
        }
    }

    init(_ ns: [UInt], _ offset: UInt, _ strides: [UInt]) {
        shape = (ns[0], ns[1])
        dataoff = offset
        datastd = (strides[0], strides[1])
    }
    
    init(_ sq_size: UInt) {
        shape = (sq_size, sq_size)
        dataoff = 0
        datastd = (1, sq_size)
    }
    init(_ ns: [UInt]) {
        shape = (ns[0], ns[1])
        dataoff = 0
        datastd = (1, ns[0])
    }
    init(_ mv: MatrixMemView) {
        shape = mv.shape
        dataoff = mv.dataoff
        datastd = mv.datastd
    }

    //MARK: accessors

    /// return a view of the _idx_-th row of this view
    func row(_ idx: UInt) -> MatrixMemView {
        let off: UInt = data_index(idx, 0)
        return MatrixMemView([1, shape.ncols], off, [datastd.row_stride, datastd.col_stride])
    }
    /// return a view of the _idx_-th col of this view
    func col(_ idx: UInt) -> MatrixMemView {
        let off: UInt = data_index(0, idx)
        return MatrixMemView([shape.nrows, 1], off, [datastd.row_stride, datastd.col_stride])
    }
    
    func transpose() -> MatrixMemView {
        return MatrixMemView([shape.ncols, shape.nrows], dataoff, [datastd.col_stride, datastd.row_stride])
    }
}

protocol Tensor3MemViewProtocol {
    var shape: (nrows: UInt, ncols: UInt, nrnks: UInt) {get}
    var dataoff: UInt {get}
    var datastd: (row_stride: UInt, col_stride: UInt, rnk_stride: UInt) {get}
}

//struct VectorMemView: VectorMemViewProtocol {
//    let shape: UInt
//    let dataoff: UInt
//    let datastd: UInt
//
//    init(_ n: UInt) {
//        
//    }
//    
//    init(_ v: Vector) {
//        
//    }
//    
//    init(_ n: UInt, _ offset: UInt, _ stride: UInt) {
//        
//    }
//
//}
