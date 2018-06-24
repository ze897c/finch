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
                    let mmv = MatrixMemView(sq_size: 3)
                    expect(mmv).to(beAKindOf(MatrixMemView.self))
                } // fit("<#fit#>")
                fit("has right properties") {
                    for n in 1 ..< UInt(13) {
                        let mmv = MatrixMemView(sq_size: n)
                        expect(mmv.shape.nrows).to(equal(n))
                        expect(mmv.shape.ncols).to(equal(n))
                        expect(mmv.dataoff).to(equal(0))
                        expect(mmv.datastd.row_stride).to(equal(1))
                        expect(mmv.datastd.col_stride).to(equal(n))
                        expect(mmv.required_capacity()).to(equal(n * n))
                    }
                } //
                
            } // context("default square")
        } //describe("int")
    } // spec()
} // class MatrixMemViewSpec:
