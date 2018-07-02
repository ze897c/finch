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
        // MARK: row view
        describe("row view") {
            context("on simple data") {
                var mv11:MatrixMemView = MatrixMemView([1, 1])
                var mv13:MatrixMemView = MatrixMemView([1, 3])
                var mv31:MatrixMemView = MatrixMemView([3, 1])
                var mv32:MatrixMemView = MatrixMemView([3, 2])
                var mv23:MatrixMemView = MatrixMemView([2, 3])
                beforeEach() {
                    mv11 = MatrixMemView([1, 1])
                    mv13 = MatrixMemView([1, 3])
                    mv31 = MatrixMemView([3, 1])
                    mv32 = MatrixMemView([3, 2])
                    mv23 = MatrixMemView([2, 3])
                }
                
                fit("is correct type") {
                    let rv11 = mv11.row(0)
                    let rv13 = mv11.row(0)
                    let rv31 = mv11.row(0)
                    let rv23 = mv11.row(0)
                    let rv32 = mv11.row(0)
                    
                    expect(rv11).to(beAKindOf(MatrixMemView.self))
                    expect(rv13).to(beAKindOf(MatrixMemView.self))
                    expect(rv31).to(beAKindOf(MatrixMemView.self))
                    expect(rv23).to(beAKindOf(MatrixMemView.self))
                    expect(rv32).to(beAKindOf(MatrixMemView.self))
                    
                } //fit("builds correctly")
                
                fit("leaves original") {
                    //
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("row view")
        
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
                } // fit("is right type")

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
                } // fit("has right properties")
                
            } // context("full boat")

            // MARK: generic shape
            context("generic shape") {
                
                fit("is right type") {
                    let mmv = MatrixMemView([3, 4])
                    expect(mmv).to(beAKindOf(MatrixMemView.self))
                } // fit("is right type")

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
                } // fit("has right properties")
                
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
                } // fit("has right properties")
                
            } // context("default square")
        } //describe("int")
    } // spec()
} // class MatrixMemViewSpec:
