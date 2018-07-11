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
        var A = Matrix(1)
        var B = Matrix(1)

        // MARK: matrix multiplication
        describe("matrix multiplication") {
            context("on simple data") {
                let d0: [[CDouble]] = [[1, -2], [-4.5, 6.7]]
                let d1: [[CDouble]] = [[CDouble.pi, -CDouble.pi], [-CDouble.pi, CDouble.pi]]

                beforeEach() {
                    A = Matrix(d0)!
                    B = Matrix(d1)!
                }
                
                fit("computes correctly") {
                    let C = (A * B)!
                    
                    expect(C).to(beAKindOf(Matrix.self))
                    expect(C.nrows).to(equal(A.nrows))
                    expect(C.ncols).to(equal(A.ncols))
                    
                    for idx in 0 ..< A.nrows {
                        for jdx in 0 ..< A.ncols {
                            let truth: CDouble = A[idx][0] * B[0][jdx] + A[idx][1] * B[1][jdx]
                            expect(C[idx][jdx]).to(equal(truth))
                        }
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    // <#code#>
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("matrix multiplication")
        
        // MARK: rows
        describe("rows") {
            
            context("on simple data") {
                let d0: [[CDouble]] = [[1, -2, 3], [-4.5, 6.7, -8]]
                let d1: [[CDouble]] = [[CDouble.pi, -CDouble.pi, CDouble.pi], [-CDouble.pi, CDouble.pi, -CDouble.pi]]
                
                beforeEach() {
                    A = Matrix(d0)!
                    B = Matrix(d1)!
                }

                fit("gets correctly") {
                    var idx: UInt = 0
                    for row in A {
                        expect(row).to(beAKindOf(Vector.self))
                        expect(row.count).to(equal(UInt(d0[0].count)))
                        for jdx in 0..<A.ncols {
                            expect(row[jdx]).to(equal(d0[Int(idx)][Int(jdx)]))
                        }
                        idx += 1
                    }
                } //fit("gets correctly")

                fit("leaves original") {
                    var idx: UInt = 0
                    for row in A {
                        expect(row.count).to(equal(UInt(d0[0].count)))
                        for jdx in 0..<A.ncols {
                            expect(row[jdx]).to(equal(d0[Int(idx)][Int(jdx)]))
                        }
                        idx += 1
                    }
                    for idx in 0 ..< A.nrows {
                        for jdx in 0 ..< A.ncols {
                            expect(A[idx][jdx]).to(equal(d0[Int(idx)][Int(jdx)]))
                        }
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("rows")
        
        // MARK: addition
        describe("addition") {
            let d0: [[CDouble]] = [[1, -2, 3], [-4.5, 6.7, -8]]
            let d1: [[CDouble]] = [[CDouble.pi, -CDouble.pi, CDouble.pi], [-CDouble.pi, CDouble.pi, -CDouble.pi]]
            context("on simple data") {
                beforeEach() {
                    A = Matrix(d0)!
                    B = Matrix(d1)!
                }

                fit("computes correctly") {
                    let C = try! A + B
                    expect(C).to(beAKindOf(Matrix.self))
                    expect(C.nrows).to(equal(A.nrows))
                    expect(C.ncols).to(equal(A.ncols))
                    for idx in 0 ..< C.nrows {
                        for jdx in 0 ..< C.ncols {
                            let truth = d0[Int(idx)][Int(jdx)] + d1[Int(idx)][Int(jdx)]
                            expect(C[idx][jdx]).to(equal(truth))
                        }
                    }
                } //fit("computes correctly")

                fit("leaves original") {
                    _ = try! A + B
                    for idx in 0 ..< A.nrows {
                        for jdx in 0 ..< A.ncols {
                            expect(A[idx][jdx]).to(equal(d0[Int(idx)][Int(jdx)]))
                            expect(B[idx][jdx]).to(equal(d1[Int(idx)][Int(jdx)]))
                        }
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("addition")

        // MARK: subtraction
        describe("subtraction") {
            let d0: [[CDouble]] = [[1, -2, 3], [-4.5, 6.7, -8]]
            let d1: [[CDouble]] = [[CDouble.pi, -CDouble.pi, CDouble.pi], [-CDouble.pi, CDouble.pi, -CDouble.pi]]
            context("on simple data") {
                beforeEach() {
                    A = Matrix(d0)!
                    B = Matrix(d1)!
                }
                
                fit("computes correctly") {
                    let C = try! A - B
                    expect(C).to(beAKindOf(Matrix.self))
                    expect(C.nrows).to(equal(A.nrows))
                    expect(C.ncols).to(equal(A.ncols))
                    for idx in 0 ..< C.nrows {
                        for jdx in 0 ..< C.ncols {
                            let truth = d0[Int(idx)][Int(jdx)] - d1[Int(idx)][Int(jdx)]
                            expect(C[idx][jdx]).to(equal(truth))
                        }
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = try! A - B
                    for idx in 0 ..< A.nrows {
                        for jdx in 0 ..< A.ncols {
                            expect(A[idx][jdx]).to(equal(d0[Int(idx)][Int(jdx)]))
                            expect(B[idx][jdx]).to(equal(d1[Int(idx)][Int(jdx)]))
                        }
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("subtraction")
 
        // MARK: scale
        describe("scale") {
            let d0: [[CDouble]] = [[1, -2, 3], [-4.5, 6.7, -8]]
            let d1: [[CDouble]] = [[CDouble.pi, -CDouble.pi, CDouble.pi], [-CDouble.pi, CDouble.pi, -CDouble.pi]]
            let a: CDouble = -CDouble.pi
            let b: CDouble = 13.079
            context("on simple data") {
                beforeEach() {
                    A = Matrix(d0)!
                    B = Matrix(d1)!
                }
                
                fit("computes correctly") {
                    let aA = a * A
                    let bB = B * b
                    expect(aA).to(beAKindOf(Matrix.self))
                    expect(aA.nrows).to(equal(A.nrows))
                    expect(aA.ncols).to(equal(A.ncols))
                    expect(bB).to(beAKindOf(Matrix.self))
                    expect(bB.nrows).to(equal(A.nrows))
                    expect(bB.ncols).to(equal(A.ncols))
                    for idx in 0 ..< aA.nrows {
                        for jdx in 0 ..< aA.ncols {
                            let truth = a * d0[Int(idx)][Int(jdx)]
                            expect(aA[idx][jdx]).to(equal(truth))
                        }
                    }
                    for idx in 0 ..< bB.nrows {
                        for jdx in 0 ..< bB.ncols {
                            let truth = b * d1[Int(idx)][Int(jdx)]
                            expect(bB[idx][jdx]).to(equal(truth))
                        }
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = try! A - B
                    for idx in 0 ..< A.nrows {
                        for jdx in 0 ..< A.ncols {
                            expect(A[idx][jdx]).to(equal(d0[Int(idx)][Int(jdx)]))
                            expect(B[idx][jdx]).to(equal(d1[Int(idx)][Int(jdx)]))
                        }
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("scale")
        
        // TODO: test that *Vector* from *Matrix* lives & works after *Matrix* deletion
        
        // MARK: functional init
        describe("functional init") {
            context("on simple data") {
                //
                let f0 = {(idx: UInt, jdx: UInt) -> CDouble in return CDouble(idx ^ jdx)}
                beforeEach() {
                    //
                }

                fit("inits data correctly") {
                    A = Matrix(3, 4, f0)
                    for idx in 0 ..< A.nrows {
                        for jdx in 0 ..< A.ncols {
                            let ddx: Int = Int(A.memview.data_index(idx, jdx))
                            expect(A.datacon[ddx]).to(beCloseTo(CDouble(idx ^ jdx)))
                        }
                    }
                } //fit("inits data correctly")
                
                fit("has correct properties") {
                    let A = Matrix(3, 4, f0)
                    expect(A.nrows).to(equal(3))
                    expect(A.ncols).to(equal(4))
                    expect(A.datacon.count).to(equal(3 * 4))
                } //fit("has correct properties")
                
            } // context("on simple data")
        } //describe("functional init")
        
        // MARK: subscript
        describe("subscript") {
            var A: Matrix? = nil
            
            context("when getting value in 3x2") {
                beforeEach() {
                    A = Matrix([[1, 2, 3], [4, 5, 6]])!
                }
                
                fit("sets correctly") {
                    A![0][0] = 6
                    A![0][1] = 5
                    A![0][2] = 4
                    A![1][0] = 3
                    A![1][1] = 2
                    A![1][2] = 1
                    expect(A!.datacon[0]).to(equal(6))
                    expect(A!.datacon[1]).to(equal(3))
                    expect(A!.datacon[2]).to(equal(5))
                    expect(A!.datacon[3]).to(equal(2))
                    expect(A!.datacon[4]).to(equal(4))
                    expect(A!.datacon[5]).to(equal(1))
                } // fit("sets correctly")
                
            } // context("when getting value in 3x2")
            
            context("when getting value from 3x2") {
                beforeEach() {
                    A = Matrix([[1, 2, 3], [4, 5, 6]])!
                }
                fit("gets correct value") {
                    expect(A![0][0]).to(equal(1))
                    expect(A![0][1]).to(equal(2))
                    expect(A![0][2]).to(equal(3))
                    expect(A![1][0]).to(equal(4))
                    expect(A![1][1]).to(equal(5))
                    expect(A![1][2]).to(equal(6))
                } // fit("gets correct value")
                
                fit("leaves original") {
                    _ = A![0][0]
                    _ = A![0][1]
                    _ = A![0][2]
                    _ = A![1][0]
                    _ = A![1][1]
                    _ = A![1][2]
                    expect(A!.datacon[0]).to(equal(1))
                    expect(A!.datacon[1]).to(equal(4))
                    expect(A!.datacon[2]).to(equal(2))
                    expect(A!.datacon[3]).to(equal(5))
                    expect(A!.datacon[4]).to(equal(3))
                    expect(A!.datacon[5]).to(equal(6))
                } // fit("leaves original")
                
            } // context("when getting row from 3x2")
            
            context("when setting row of 3x2") {
                beforeEach() {
                    A = Matrix([[1, 2, 3], [4, 5, 6]])!
                }
                
                fit("sets row") {
                    A![0] = Vector([[7, 8, 9]])!
                    expect(A!.datacon[0]).to(equal(7))
                    expect(A!.datacon[2]).to(equal(8))
                    expect(A!.datacon[4]).to(equal(9))
                } // fit("sets row")
                
                fit("leaves original") {
                    A![0] = Vector([[7, 8, 9]])!
                    expect(A!.datacon[1]).to(equal(4))
                    expect(A!.datacon[3]).to(equal(5))
                    expect(A!.datacon[5]).to(equal(6))
                } // fit("leaves original")
            } // context("when setting row of 3x2")
            
            context("when getting row from 3x2") {

                beforeEach() {
                    A = Matrix([[1, 2, 3], [4, 5, 6]])!
                }
                
                fit("gets Matrix") {
                    let r0 = A![0]
                    expect(r0).to(beAKindOf(Vector.self))
                    let r1 = A![1]
                    expect(r1).to(beAKindOf(Vector.self))
                } //fit("gets Matrix")
                
                fit("gets row") {
                    let r0 = A![0]
                    expect(r0.isRowVector).to(beTrue())
                    let r1 = A![1]
                    expect(r1.isRowVector).to(beTrue())
                } // fit("gets row")
                
                fit("leaves original") {
                    _ = A![0]
                    _ = A![1]
                    expect(A!.datacon[0]).to(equal(1))
                    expect(A!.datacon[1]).to(equal(4))
                    expect(A!.datacon[2]).to(equal(2))
                    expect(A!.datacon[3]).to(equal(5))
                    expect(A!.datacon[4]).to(equal(3))
                    expect(A!.datacon[5]).to(equal(6))
                } // fit("leaves original")
                
                fit("is view into parent") {
                    let r0 = A![0]
                    let r1 = A![1]
                    expect(r0.datacon).to(beIdenticalTo(A!.datacon))
                    expect(r1.datacon).to(beIdenticalTo(A!.datacon))
                } // fit("is view into parent")
                
                fit("has correct memview details") {
                    let r0 = A![0]
                    let r1 = A![1]
                    expect(r0.memview.dataoff).to(equal(0))
                    expect(r1.memview.dataoff).to(equal(1))
                    expect(r0.memview.row_stride).to(equal(A?.memview.row_stride))
                    expect(r0.memview.col_stride).to(equal(A?.memview.col_stride))
                } // fit("has correct memview details")
                
            } // context("when getting row from 3x2")
        } //describe("subscript")

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
            
            context("from Swift double-indexed") {
                
                fit("ill-formed is nil") {
                    let Z = Matrix([[1, 2, 3], [4, 5]])
                    expect(Z).to(beNil())
                } // fit("ill-formed is nil")

                fit("well-formed is not nil") {
                    let A = Matrix([[1, 2, 3], [4, 5, 6]])
                    expect(A).toNot(beNil())
                } // fit("well-formed is not nil")

                fit("well-formed has correct shape") {
                    let A = Matrix([[1, 2, 3], [4, 5, 6]])!
                    expect(A.nrows).to(equal(2))
                    expect(A.ncols).to(equal(3))
                } // fit("well-formed has correct shape")

                fit("has correct data in datacon") {
                    let A = Matrix([[1, 2, 3], [4, 5, 6]])!
                    expect(A.datacon[0]).to(equal(1))
                    expect(A.datacon[1]).to(equal(4))
                    expect(A.datacon[2]).to(equal(2))
                    expect(A.datacon[3]).to(equal(5))
                    expect(A.datacon[4]).to(equal(3))
                    expect(A.datacon[5]).to(equal(6))
                }
                
            } // context("from Swift double-indexed")
            
            context("indexed function ctor") {
                fit("has correct shape") {
                    for m in UInt(1) ..< UInt(4) {
                        for n in UInt(1) ..< UInt(4) {
                            let A = Matrix(m, n, {(idx: UInt, jdx: UInt) in
                                return CDouble(idx * jdx)
                            })
                            expect(A.shape.nrows).to(equal(m))
                            expect(A.shape.ncols).to(equal(n))
                        }
                    }
                } // fit("has correct shape")
                
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
                fit("works for n < 10") {
                    for n in UInt(1) ..< UInt(10) {
                        let A = Matrix(n)
                        expect(A.shape.nrows).to(equal(n))
                        expect(A.shape.ncols).to(equal(n))
                        
                    }
                } //fit("works for n < 10")
                
                fit("has correct memview details") {
                    for n in UInt(1) ..< UInt(10) {
                        let A = Matrix(n)
                        expect(A.datacon.count).to(equal(n * n))
                        expect(A.memview.row_stride).to(equal(1))
                        expect(A.memview.col_stride).to(equal(n))
                    }
                } // fit("has correct memview details")

            } // context("square matrix ctor")
            
            context("general init ctor") {
                fit("inits correct shape") {
                    for m in UInt(1) ..< UInt(5) {
                        for n in UInt(1) ..< UInt(5) {
                            let A = Matrix(m, n)
                            expect(A.shape.nrows).to(equal(m))
                            expect(A.shape.ncols).to(equal(n))
                        }
                    }
                } // fit("inits correct shape")
                fit("has correct memview details") {
                    for m in UInt(1) ..< UInt(5) {
                        for n in UInt(1) ..< UInt(5) {
                            let A = Matrix(m, n)
                            expect(A.datacon.count).to(equal(m * n))
                            expect(A.memview.row_stride).to(equal(1))
                            expect(A.memview.col_stride).to(equal(m))
                        }
                    }
                } // fit("has correct memview details")
            } // context("general init ctor")
            
            context("deepcopy ctor") {
                
                fit("creates copy") {
                    let A = Matrix(3)
                    let B = Matrix(deepCopyFrom: A)
                    expect(A.shape.nrows).to(equal(B.shape.nrows))
                    expect(A.shape.ncols).to(equal(B.shape.ncols))
                    for idx in 0 ..< 9 {
                        expect(B.datacon[idx]).to(equal(A.datacon[idx]))
                    }
                } //fit("creates copy")
                
                fit("creates deep copy") {
                    let newval: CDouble = 1999.99
                    let A = Matrix(3)
                    let B = Matrix(deepCopyFrom: A)
                    B.datacon[0] = newval
                    expect(B.datacon[0]).to(equal(newval))
                    expect(A.datacon[0]).toNot(equal(newval))
                } //fit("creates deep copy")
                
            } // context("deepcopy ctor")
        } //describe("init")
    } // spec()
} // class MatrixSpec
