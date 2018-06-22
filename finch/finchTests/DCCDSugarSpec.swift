//
//  DCCDSugarSpec.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/21/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

import Nimble
import Quick
import XCTest
import os.log

@testable import finch


//extension CDouble {
//    var small: CDouble {
//        get {
//            return 1.0e-15
//        }
//    }
//    func near(_ x: CDouble, tol: CDouble? = nil) -> Bool {
//        return abs(x - self) < (tol ?? small)
//    }
//}


class DCCDSugarSpec: QuickSpec {
    var dc0: DataCon<CDouble> = DataCon<CDouble>()
    var dc1: DataCon<CDouble> = DataCon<CDouble>()
    var dc2: DataCon<CDouble> = DataCon<CDouble>()
    var dc3: DataCon<CDouble> = DataCon<CDouble>()
    var X: DataCon<CDouble> = DataCon<CDouble>()
    var Y: DataCon<CDouble> = DataCon<CDouble>()
    var Z: DataCon<CDouble> = DataCon<CDouble>()
    var XYZ: DataCon<CDouble> = DataCon<CDouble>()
//    let v0: [CDouble] = [1.4, -2.2, 4.5]
//    let v1: [CDouble] = [CDouble.pi, -CDouble.pi, CDouble.pi]
//
//    var linspace: DataCon<CDouble>?
    
    let x: [CDouble] = [1, 0, 0]
    let y: [CDouble] = [0, 1, 0]
    let z: [CDouble] = [0, 0, 1]
    let xyz: [CDouble] = [1, 1, 1]
    let sqrt2: CDouble = sqrt(2.0)

    override func spec() {
        
        // MARK: compound -= operator
        describe("compound -= operator") {
            context("on simple data") {
                beforeEach() {
                    self.X = DataCon<CDouble>(elements: self.x)
                    self.Y = DataCon<CDouble>(elements: self.y)
                    self.Z = DataCon<CDouble>(elements: self.z)
                    self.XYZ = DataCon<CDouble>(elements: self.xyz)
                }
                
                fit("computes correctly") {
                    self.XYZ -= self.X
                    for idx in 0 ..< 3 {
                        expect(self.XYZ[idx]).to(equal(self.xyz[idx] - self.x[idx]))
                    }
                    self.XYZ -= self.Y
                    for idx in 0 ..< 3 {
                        expect(self.XYZ[idx]).to(equal(self.xyz[idx] - self.x[idx] - self.y[idx]))
                    }
                    self.XYZ -= self.Z
                    for idx in 0 ..< 3 {
                        expect(self.XYZ[idx]).to(equal(self.xyz[idx] - self.x[idx] - self.y[idx] - self.z[idx]))
                    }
                } //fit("computes correctly")

                fit("leaves original") {
                    self.XYZ -= self.X
                    self.XYZ -= self.Y
                    self.XYZ -= self.Z
                    for idx in 0 ..< 3 {
                        expect(self.X[idx]).to(equal(self.x[idx]))
                        expect(self.Y[idx]).to(equal(self.y[idx]))
                        expect(self.Z[idx]).to(equal(self.z[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("compound -= operator")
        
        // MARK: "infix operator -"
        describe("infix operator -") {
            context("on simple data") {

                beforeEach() {
                    self.X = DataCon<CDouble>(elements: self.x)
                    self.Y = DataCon<CDouble>(elements: self.y)
                    self.Z = DataCon<CDouble>(elements: self.z)
                    self.XYZ = DataCon<CDouble>(elements: self.xyz)
                }
                
                fit("computes correctly") {
                    let Xm = -self.X
                    let Ym = -self.Y
                    let Zm = -self.Z
                    let XYZm = -self.XYZ
                    for idx in 0 ..< 3 {
                        expect(Xm[idx]).to(equal(-self.x[idx]))
                        expect(Ym[idx]).to(equal(-self.y[idx]))
                        expect(Zm[idx]).to(equal(-self.z[idx]))
                        expect(XYZm[idx]).to(equal(-self.xyz[idx]))
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = -self.X
                    _ = -self.Y
                    _ = -self.Z
                    _ = -self.XYZ
                    for idx in 0 ..< 3 {
                        expect(self.X[idx]).to(equal(self.x[idx]))
                        expect(self.Y[idx]).to(equal(self.y[idx]))
                        expect(self.Z[idx]).to(equal(self.z[idx]))
                        expect(self.XYZ[idx]).to(equal(self.xyz[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("<#desc#>")
        
        // MARK: binary operator -
        describe("binary operator -") {
            context("on simple data") {
                beforeEach() {
                    self.X = DataCon<CDouble>(elements: self.x)
                    self.Y = DataCon<CDouble>(elements: self.y)
                    self.Z = DataCon<CDouble>(elements: self.z)
                    self.XYZ = DataCon<CDouble>(elements: self.xyz)
                }
                
                fit("computes correctly") {
                    let XmY = self.X - self.Y
                    let YmX = self.Y - self.X
                    let XmZ = self.X - self.Z
                    let ZmX = self.Z - self.X
                    let YmZ = self.Y - self.Z
                    let ZmY = self.Z - self.Y
                    let XYZmX = self.XYZ - self.X
                    let XYZmY = self.XYZ - self.Y
                    let XYZmZ = self.XYZ - self.Z
                    for idx in 0 ..< 3 {
                        expect(XmY[idx]).to(beCloseTo(self.x[idx] - self.y[idx], within: CDouble.small))
                        expect(YmX[idx]).to(beCloseTo(self.y[idx] - self.x[idx], within: CDouble.small))
                        expect(XmZ[idx]).to(beCloseTo(self.x[idx] - self.z[idx], within: CDouble.small))
                        expect(ZmX[idx]).to(beCloseTo(self.z[idx] - self.x[idx], within: CDouble.small))
                        expect(YmZ[idx]).to(beCloseTo(self.y[idx] - self.z[idx], within: CDouble.small))
                        expect(ZmY[idx]).to(beCloseTo(self.z[idx] - self.y[idx], within: CDouble.small))
                        expect(XYZmX[idx]).to(beCloseTo(self.xyz[idx] - self.x[idx], within: CDouble.small))
                        expect(XYZmY[idx]).to(beCloseTo(self.xyz[idx] - self.y[idx], within: CDouble.small))
                        expect(XYZmZ[idx]).to(beCloseTo(self.xyz[idx] - self.z[idx], within: CDouble.small))
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = self.X - self.Y
                    _ = self.X - self.Z
                    _ = self.Y - self.Z
                    for idx in 0 ..< 3 {
                        expect(self.X[idx]).to(equal(self.x[idx]))
                        expect(self.Y[idx]).to(equal(self.y[idx]))
                        expect(self.Z[idx]).to(equal(self.z[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe("binary operator -")
        
    } // override func spec()
} // class DCCDSugarSpec: QuickSpec

