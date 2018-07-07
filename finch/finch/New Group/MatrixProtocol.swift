//
//  MatrixProtocol.swift
//  finch
//
//  Created by Matthew Patterson on 7/3/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

protocol MatrixProtocol {
    var memview: MatrixMemView {get}

    var shape: (nrows: UInt, ncols: UInt) {get}
    var nrows: UInt {get}
    var ncols: UInt {get}
    var isRowVector: Bool {get}
    var isColVector: Bool {get}
}

extension MatrixProtocol {
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

}
