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
        var mv11:MatrixMemView = MatrixMemView([1, 1])
        var mv13:MatrixMemView = MatrixMemView([1, 3])
        var mv31:MatrixMemView = MatrixMemView([3, 1])
        var mv32:MatrixMemView = MatrixMemView([3, 2])
        var mv23:MatrixMemView = MatrixMemView([2, 3])

        // MARK: encode
        describe("encode") {
            context("on simple data") {
                beforeEach() {
                    mv32 = MatrixMemView([3, 2])
                    mv23 = MatrixMemView([2, 3])
                }
                
                fit("encodes and decodes") {
                    let encoder = JSONEncoder()
                    let decoder = JSONDecoder()
                    var jsonData23 = try! encoder.encode(mv23)
                    let jsonData32 = try! encoder.encode(mv32)
                    //let jsonString = String(data: jsonData, encoding: .utf8)
                    expect(1).to(equal(1)) // just making sure we made it this far

                    // ?? just figuring out how to do python.id
//                    var jimmy = jsonData23
//                    withUnsafePointer(to: &jsonData23) {
//                        print("value has address: \($0)")
//                    }
//                    withUnsafePointer(to: &jimmy) {
//                        print("eulav has address: \($0)")
//                    }
                    
                    do {
                        let re_mv23 = try decoder.decode(MatrixMemView.self, from: jsonData23)
                        let re_mv32 = try decoder.decode(MatrixMemView.self, from: jsonData32)
                        expect(re_mv23).to(beAKindOf(MatrixMemView.self))
                        expect(re_mv32).to(beAKindOf(MatrixMemView.self))
                    } catch _ {
                        // TODO: there must be a way to handle this from Q/N
                        fail()
                    }
                    
                    
                } //fit("encodes and decodes")
                
                fit("leaves original") {
                    // <#code#>
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("encode")
        
        
        // MARK: col view
        describe("col view") {

            context("on simple data") {

                beforeEach() {
                    mv11 = MatrixMemView([1, 1])
                    mv13 = MatrixMemView([1, 3])
                    mv31 = MatrixMemView([3, 1])
                    mv32 = MatrixMemView([3, 2])
                    mv23 = MatrixMemView([2, 3])
                }
                
                fit("is correct type") {
                    let rv110 = mv11.col(0)
                    expect(rv110).to(beAKindOf(MatrixMemView.self))

                    let rv130 = mv13.col(0)
                    expect(rv130).to(beAKindOf(MatrixMemView.self))

                    let rv310 = mv31.col(0)
                    let rv311 = mv31.col(1)
                    let rv312 = mv31.col(2)
                    expect(rv310).to(beAKindOf(MatrixMemView.self))
                    expect(rv311).to(beAKindOf(MatrixMemView.self))
                    expect(rv312).to(beAKindOf(MatrixMemView.self))

                    let rv230 = mv23.col(0)
                    let rv231 = mv23.col(1)
                    expect(rv230).to(beAKindOf(MatrixMemView.self))
                    expect(rv231).to(beAKindOf(MatrixMemView.self))

                    let rv320 = mv32.col(0)
                    let rv321 = mv32.col(1)
                    let rv322 = mv32.col(2)
                    expect(rv320).to(beAKindOf(MatrixMemView.self))
                    expect(rv321).to(beAKindOf(MatrixMemView.self))
                    expect(rv322).to(beAKindOf(MatrixMemView.self))

                } //fit("builds correctly")
                
                fit("is correct form") {
                    let rv11 = mv11.col(0)
                    expect(rv11.shape.nrows).to(equal(1))
                    expect(rv11.shape.ncols).to(equal(1))
                    
                    let rv130 = mv13.col(0)
                    expect(rv130.shape.nrows).to(equal(1))
                    expect(rv130.shape.ncols).to(equal(1))

                    let rv131 = mv13.col(1)
                    expect(rv131.shape.nrows).to(equal(1))
                    expect(rv131.shape.ncols).to(equal(1))

                    let rv132 = mv13.col(2)
                    expect(rv132.shape.nrows).to(equal(1))
                    expect(rv132.shape.ncols).to(equal(1))
                    
                    let rv310 = mv31.col(0)
                    expect(rv310.shape.nrows).to(equal(3))
                    expect(rv310.shape.ncols).to(equal(1))
                    
                    let rv311 = mv31.col(1)
                    expect(rv311.shape.nrows).to(equal(3))
                    expect(rv311.shape.ncols).to(equal(1))
                    
                    let rv312 = mv31.col(2)
                    expect(rv312.shape.nrows).to(equal(3))
                    expect(rv312.shape.ncols).to(equal(1))
                    
                    let rv230 = mv23.col(0)
                    expect(rv230.shape.nrows).to(equal(2))
                    expect(rv230.shape.ncols).to(equal(1))
                    
                    let rv231 = mv23.col(1)
                    expect(rv231.shape.nrows).to(equal(2))
                    expect(rv231.shape.ncols).to(equal(1))
                    
                    let rv232 = mv23.col(2)
                    expect(rv232.shape.nrows).to(equal(2))
                    expect(rv232.shape.ncols).to(equal(1))
                    
                    let rv320 = mv32.col(0)
                    expect(rv320.shape.nrows).to(equal(3))
                    expect(rv320.shape.ncols).to(equal(1))
                    
                    let rv321 = mv32.col(1)
                    expect(rv321.shape.nrows).to(equal(3))
                    expect(rv321.shape.ncols).to(equal(1))

                } //fit("is correct form")
                
            } // context("on simple data")
        } //describe("col view")

        // MARK: row view
        describe("row view") {
            context("on simple data") {

                beforeEach() {
                    mv11 = MatrixMemView([1, 1])
                    mv13 = MatrixMemView([1, 3])
                    mv31 = MatrixMemView([3, 1])
                    mv32 = MatrixMemView([3, 2])
                    mv23 = MatrixMemView([2, 3])
                }
                
                fit("is correct type") {
                    let rv11 = mv11.row(0)
                    let rv13 = mv13.row(0)
                    let rv31 = mv31.row(0)
                    let rv23 = mv23.row(0)
                    let rv32 = mv32.row(0)
                    
                    expect(rv11).to(beAKindOf(MatrixMemView.self))
                    expect(rv13).to(beAKindOf(MatrixMemView.self))
                    expect(rv31).to(beAKindOf(MatrixMemView.self))
                    expect(rv23).to(beAKindOf(MatrixMemView.self))
                    expect(rv32).to(beAKindOf(MatrixMemView.self))
                } //fit("builds correctly")
                
                fit("is correct form") {
                    let rv11 = mv11.row(0)
                    expect(rv11.shape.nrows).to(equal(1))
                    expect(rv11.shape.ncols).to(equal(1))
                    
                    let rv13 = mv13.row(0)
                    expect(rv13.shape.nrows).to(equal(1))
                    expect(rv13.shape.ncols).to(equal(3))
                    
                    let rv310 = mv31.row(0)
                    expect(rv310.shape.nrows).to(equal(1))
                    expect(rv310.shape.ncols).to(equal(1))
                    
                    let rv311 = mv31.row(1)
                    expect(rv311.shape.nrows).to(equal(1))
                    expect(rv311.shape.ncols).to(equal(1))
                    
                    let rv312 = mv31.row(2)
                    expect(rv312.shape.nrows).to(equal(1))
                    expect(rv312.shape.ncols).to(equal(1))

                    let rv230 = mv23.row(0)
                    expect(rv230.shape.nrows).to(equal(1))
                    expect(rv230.shape.ncols).to(equal(3))
                    
                    let rv231 = mv23.row(1)
                    expect(rv231.shape.nrows).to(equal(1))
                    expect(rv231.shape.ncols).to(equal(3))

                    let rv320 = mv32.row(0)
                    expect(rv320.shape.nrows).to(equal(1))
                    expect(rv320.shape.ncols).to(equal(2))

                    let rv321 = mv32.row(1)
                    expect(rv321.shape.nrows).to(equal(1))
                    expect(rv321.shape.ncols).to(equal(2))

                    let rv322 = mv32.row(2)
                    expect(rv322.shape.nrows).to(equal(1))
                    expect(rv322.shape.ncols).to(equal(2))
                } //fit("is correct form")
                
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
                    let mmv = MatrixMemView([m, n], UInt(2), [UInt(1), m])
                    expect(mmv).to(beAKindOf(MatrixMemView.self))
                } // fit("is right type")

                fit("has right properties") {
                    for m in 3 ..< UInt(5) {
                        for n in 3 ..< UInt(7) {
                            for off in 0 ..< UInt(4) {
                                let mmv = MatrixMemView([m, n], off, [UInt(1), m])
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
