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
        // MARK: static builder
        describe("static builder") {
            
            context("Eye") {
                fit("builds correctly") {
                    for n in UInt(1) ..< UInt(5) {
                        let A = Matrix.Eye(n)
                        expect(A.shape.nrows).to(equal(n))
                        expect(A.shape.ncols).to(equal(n))
                        for idx in UInt(0) ..< n * n {
                            if idx % n == 0 {
                                expect(A.datacon[DataCon<CDouble>.Index(idx)]).to(equal(1.0))
                            } else {
                                expect(A.datacon[DataCon<CDouble>.Index(idx)]).to(equal(0.0))
                            }
                        }
                    }
                } //fit("works for square")
            } // context("Eye")
            
            context("Zeros") {
                
                fit("works for square") {
                    for n in UInt(1) ..< UInt(5) {
                        let A = Matrix.Zeros(n)
                        expect(A.shape.nrows).to(equal(n))
                        expect(A.shape.ncols).to(equal(n))
                        for idx in UInt(0) ..< n * n {
                            expect(A.datacon[DataCon<CDouble>.Index(idx)]).to(equal(0.0))
                        }
                    }
                } //fit("works for square")
                
                fit("works for general") {
                    for n in UInt(1) ..< UInt(5) {
                        for m in UInt(1) ..< UInt(5) {
                            let A = Matrix.Zeros(m, n)
                            expect(A.shape.nrows).to(equal(m))
                            expect(A.shape.ncols).to(equal(n))
                            for idx in UInt(0) ..< m * n {
                                expect(A.datacon[DataCon<CDouble>.Index(idx)]).to(equal(0.0))
                            }
                        }
                    }
                } //fit("works for general")
                
            } // context("on simple data")
        } //describe("static builder")

        // MARK: init
        describe("init") {
            
            context("indexed function ctor") {
                fit("has correct form") {
                    for m in UInt(1) ..< UInt(4) {
                        for n in UInt(1) ..< UInt(4) {
                            let A = Matrix(m, n, {(idx: UInt, jdx: UInt) in
                                return CDouble(idx * jdx)
                            })
                            expect(A.shape.nrows).to(equal(m))
                            expect(A.shape.ncols).to(equal(n))
                        }
                    }
                } // "has correct form"
                
                fit("has correct data") {
                    let A = Matrix(3, 5, {(idx: UInt, jdx: UInt) in
                        return CDouble(idx * jdx)
                    })
                    for idx in UInt(0) ..< UInt(3) {
                        for jdx in UInt(0) ..< UInt(5) {
                            let ddx: Int = Int(A.memview.data_index(idx, jdx))
                            expect(A.datacon[ddx]).to(equal(CDouble(idx * jdx)))
                        }
                    }
                } // "has correct data"
            } // context("indexed function ctor")
            
            context("square matrix ctor") {
                fit("works in simple cases") {
                    for n in UInt(1) ..< UInt(10) {
                        let A = Matrix(n)
                        expect(A.shape.nrows).to(equal(n))
                        expect(A.shape.ncols).to(equal(n))
                        expect(A.datacon.count).to(equal(n * n))
                    }
                } //fit("works in simple cases")
                
            } // context("square matrix ctor")
            
            context("deepcopy ctor") {
                
                fit("creates copy") {
                    let A = Matrix(3)
                    let B = Matrix(A)
                    expect(A.shape.nrows).to(equal(B.shape.nrows))
                    expect(A.shape.ncols).to(equal(B.shape.ncols))
                    for idx in 0 ..< 9 {
                        expect(B.datacon[idx]).to(equal(A.datacon[idx]))
                    }
                } //fit("creates copy")
                
                fit("creates deep copy") {
                    let newval: CDouble = 1999.99
                    let A = Matrix(3)
                    let B = Matrix(A)
                    B.datacon[0] = newval
                    expect(B.datacon[0]).to(equal(newval))
                    expect(A.datacon[0]).toNot(equal(newval))
                } //fit("creates deep copy")
                
            } // context("deepcopy ctor")
        } //describe("init")
    } // spec()
} // class MatrixSpec
