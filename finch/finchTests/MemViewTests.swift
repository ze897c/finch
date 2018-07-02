//
//  MemViewTests.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import finch

class MatrixMemViewSpec: QuickSpec {
    
    override func spec() {
        // MARK: init
        describe("init") {
            
            context("full boat") {
//                let shape: (nrows: UInt, ncols: UInt)
//                let dataoff: UInt
//                let datastd: (row_stride: UInt, col_stride: UInt)
                fit("is right type") {
                    let (m, n) = (UInt(2), UInt(3))
                    let mmv = MatrixMemView([m, n], offset: UInt(2), strides:[UInt(1), m])
                    expect(mmv).to(beAKindOf(MatrixMemView.self))
                } // fit("<#fit#>")
                fit("has right properties") {
                    for m in 3 ..< UInt(5) {
                        for n in 3 ..< UInt(7) {
                            for off in 0 ..< UInt(4) {
                                let mmv = MatrixMemView([m, n], offset: off, strides:[UInt(1), m])
                                expect(mmv.shape.nrows).to(equal(m))
                                expect(mmv.shape.ncols).to(equal(n))
                                expect(mmv.dataoff).to(equal(off))
                                expect(mmv.datastd.row_stride).to(equal(1))
                                expect(mmv.datastd.col_stride).to(equal(m))
                                expect(mmv.required_capacity()).to(equal(m * n + off))
                            }
                        }
                    }
                } //
                
            } // context("full boat")

            // MARK: generic shape
            context("generic shape") {
                
                fit("is right type") {
                    let mmv = MatrixMemView([3, 4])
                    expect(mmv).to(beAKindOf(MatrixMemView.self))
                } // fit("<#fit#>")
                fit("has right properties") {
                    for m in 1 ..< UInt(13) {
                        for n in 1 ..< UInt(13) {
                            let mmv = MatrixMemView([m, n])
                            expect(mmv.shape.nrows).to(equal(m))
                            expect(mmv.shape.ncols).to(equal(n))
                            expect(mmv.dataoff).to(equal(0))
                            expect(mmv.datastd.row_stride).to(equal(1))
                            expect(mmv.datastd.col_stride).to(equal(m))
                            expect(mmv.required_capacity()).to(equal(m * n))
                        }
                    }
                } //
                
            } // context("generic shape")
            
            context("default square") {

                fit("is right type") {
                    let mmv = MatrixMemView(3)
                    expect(mmv).to(beAKindOf(MatrixMemView.self))
                } // fit("is right type")
                fit("has right properties") {
                    for n in 1 ..< UInt(13) {
                        let mmv = MatrixMemView(n)
                        expect(mmv.shape.nrows).to(equal(n))
                        expect(mmv.shape.ncols).to(equal(n))
                        expect(mmv.dataoff).to(equal(0))
                        expect(mmv.datastd.row_stride).to(equal(1))
                        expect(mmv.datastd.col_stride).to(equal(n))
                        expect(mmv.required_capacity()).to(equal(n * n))
                    }
                } // fit("is right type")
                
            } // context("default square")
        } //describe("int")
    } // spec()
} // class MatrixMemViewSpec:
