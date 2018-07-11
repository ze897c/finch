//
//  VectorSpec.swift
//  finchTests
//
//  Created by Matthew Patterson on 7/7/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Nimble
import Quick
import XCTest
import os.log

@testable import finch

class VectorSpec: QuickSpec {
    let v0: [CDouble] = [1.0, 2.0, 3.0]
    let v1: [CDouble] = [1.0, -2.0, 3.0, -4.0, 5.0]
    let d0: [[CDouble]] = [[1, 2, 3]]
    let d1: [[CDouble]] = [[1], [2], [3]]
    
    var V0: Vector? = nil
    var V1: Vector? = nil
    var V2: Vector? = nil
    var V3: Vector? = nil
    var V4: Vector? = nil
    var V5: Vector? = nil
    override func spec() {
        
        // MARK: imaxmag
        describe("imaxmag") {
            context("on simple data") {
                let pi: CDouble = CDouble.pi
                let d2: [CDouble] = [pi, -2 * pi, -pi]
                let d3: [CDouble] = [pi, -3 * pi, 4 * pi, -pi]
                let d4: [[CDouble]] = [[pi], [-2 * pi], [-pi]]
                let d5: [[CDouble]] = [[pi], [-3 * pi], [4 * pi], [-pi]]
                
                beforeEach() {
                    self.V2 = Vector(d2)
                    self.V3 = Vector(d3)
                    self.V4 = Vector(d4)!
                    self.V5 = Vector(d5)!
                }
                
                fit("computes correctly") {
                    expect(self.V2!.imaxmag()).to(equal(1))
                    expect(self.V3!.imaxmag()).to(equal(2))
                    expect(self.V4!.imaxmag()).to(equal(1))
                    expect(self.V5!.imaxmag()).to(equal(2))
                } //fit("computes correctly")
                
                fit("leaves original") {
                    // <#code#>
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("imaxmag")
        
        // MARK: init
        describe("init") {

            context("row vector from double sequence") {
                fit("inits correctly") {
                    let V = Vector(self.d0)!
                    expect(V.count).to(equal(UInt(self.v0.count)))
                    for idx in 0 ..< UInt(self.d0[0].count) {
                        let truth = self.d0[0][Int(idx)]
                        expect(V[idx]).to(equal(truth))
                    }
                } // fit("inits correctly")
            } // context("row vector from double sequence")
            
            context("from Sequence") {

                fit("inits correctly") {
                    let V = Vector(self.v1)
                    expect(V.count).to(equal(UInt(self.v1.count)))
                    for idx in 0 ..< UInt(self.v1.count) {
                        expect(V[idx]).to(equal(self.v1[Int(idx)]))
                    }
                } // fit("inits correctly")
                
                fit("has correct properties") {
                    let V = Vector(self.v1)
                    expect(V.isColVector).to(beTrue())
                } // fit("has correct properties")
                
            } // context("from Sequence")
        } //describe("init")
        // MARK: transpose
        describe("transpose") {
            context("on simple data") {
                fit("computes correctly") {
                    let V = Vector(self.v0)
                    let W = V.transpose()
                    for idx in 0 ..< UInt(self.v0.count) {
                        expect(W[idx]).to(equal(self.v0[Int(idx)]))
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    let V = Vector(self.v0)
                    _ = V.transpose()
                    for idx in 0 ..< UInt(self.v0.count) {
                        expect(V.datacon[Int(idx)]).to(equal(self.v0[Int(idx)]))
                        expect(V[idx]).to(equal(self.v0[Int(idx)]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("transpose")
        
        // MARK: indexed functional init
        describe("indexed functional init") {
            context("on simple data") {
                let f0 = {(idx: UInt) -> CDouble in return CDouble(2 ^ idx)}

                fit("inits data correctly") {
                    let n: UInt = 7
                    let A = Vector(n, f0)
                    for idx in 0 ..< Int(n) {
                        expect(A.datacon[idx]).to(beCloseTo(CDouble(2 ^ idx)))
                    }
                } //fit("inits data correctly")
                
                fit("has correct properties") {
                    let n: UInt = 7
                    let A = Vector(n, f0)
                    expect(A.nrows).to(equal(n))
                    expect(A.ncols).to(equal(1))
                } //fit("has correct properties")
                
            } // context("on simple data")
        } //describe("indexed functional init")

    } // override func spec()
    
} // class VectorSpec: QuickSpec
