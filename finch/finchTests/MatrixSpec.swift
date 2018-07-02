//
//  MatrixSpec.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/26/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Nimble
import Quick
import XCTest
import os.log

@testable import finch

class MatrixSpec: QuickSpec {
    
    override func spec() {
        /*
         init(_ n: UInt) {
            memview = MatrixMemView(sq_size: n)
            datacon = DataCon<CDouble>(capacity: n * n)
         }
         init(_ nrows: UInt, _ ncols: UInt) {
            memview = MatrixMemView([nrows, ncols])
            datacon = DataCon<CDouble>(capacity: nrows * ncols)
         }
         
         init(_ x: Matrix) {
            memview = MatrixMemView(x.memview)
            datacon = x.datacon.deepcopy()
         }
         init(_ data_con: DataCon<CDouble>, _ mem_view: MatrixMemView) {
            datacon = data_con
            memview = mem_view
         }
         */
        
        // MARK: init
        describe("init") {
            context("square matrix ctor") {
                fit("works in simple cases") {
                    for n in UInt(1) ..< UInt(10) {
                        let A = Matrix(n)
                        expect(A.shape.nrows).to(equal(n))
                    }
                } //fit("works in simple cases")
                
            } // context("square matrix ctor")
            
            context("deepcopy ctor") {
                
                fit("creates deep copy") {
                    let A = Matrix(3)
                    let B = Matrix(A)
                    
                } //fit("creates deep copy")
                
            } // context("deepcopy ctor")
        } //describe("init")
    } // spec()
} // class MatrixSpec
