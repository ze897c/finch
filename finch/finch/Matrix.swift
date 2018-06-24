//
//  Matrix.swift
//  finch
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

// assumption here is Double, dense, no structural constraint
struct Matrix : MatrixMemViewProtocol {
    typealias Element = CDouble
    let shape: (nrows: UInt, ncols: UInt)
    let datacon: DataCon<CDouble>
    let dataoff: UInt
    let datastd: (row_stride: UInt, col_stride: UInt)
    
//    subscript(idx: UInt) -> Matrix {
//        get{
//
//        }
//        set(x: Matrix) {
//
//        }
//    }
}
