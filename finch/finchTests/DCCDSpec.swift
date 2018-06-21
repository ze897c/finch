//
//  DCCDSpec.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/20/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
// TODO: will these work?
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


class DCCDSpec: QuickSpec {

    override func spec() {
        var dc0: DataCon<CDouble>?
        let v0: [CDouble] = [1.4, -2.2, 4.5]
        let v1: [CDouble] = [CDouble.pi, -CDouble.pi, CDouble.pi]
        
        var linspace: DataCon<CDouble>?
        _ = "this a long drive for someone with nothing to think about"

        beforeEach {
            linspace = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
        }
        // MARK: .norm
        describe(".norm") {
            context("on simple data") {
                let dc0: DataCon<CDouble> = DataCon<CDouble>(elements: v0)
                let dc1: DataCon<CDouble> = DataCon<CDouble>(elements: v1)
                let truth_0: CDouble = sqrt(v0[0] * v0[0] + v0[1] * v0[1] + v0[2] * v0[2])
                let truth_1: CDouble = sqrt(v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2])

                fit("computes correctly") {
                    // .norm uses magnitude
                    let mag0 = dc0.norm
                    let mag1 = dc1.norm
                    expect(mag0).to(beCloseTo(truth_0, within: 1.0e-15))
                    expect(mag1).to(beCloseTo(truth_1, within: 1.0e-15))
                } //fit("computes correctly")
                
            } // context("on simple data")
        } //describe(".norm")
        // MARK: .dot
        describe(".dot") {
            context("on simple data") {
                let dc0: DataCon<CDouble> = DataCon<CDouble>(elements: v0)
                let dc1: DataCon<CDouble> = DataCon<CDouble>(elements: v1)
                let truth_0: CDouble = v0[0] * v0[0] + v0[1] * v0[1] + v0[2] * v0[2]
                let truth_1: CDouble = v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2]
                fit("computes correctly") {
                    let dot0 = dc0.dot(dc0)
                    let dot1 = dc1.dot(dc1)
                    expect(dot0).to(beCloseTo(truth_0, within: 1.0e-15))
                    expect(dot1).to(beCloseTo(truth_1, within: 1.0e-15))
                } //fit("computes correctly")
            } // context("on simple data ")

            let DotTimingN: UInt = 450000
            // fucking do not understand Q/N yet
            context("cblas timing") {
                dc0 = DataCon<Double>.Linspace(n: DotTimingN)
                fit("is faster") {
//                    self.measure {
//                        _ = dc0!.dot(dc0!)
//                        //print("testDotTiming result: \(x)")
//                    }
                } // fit
            }
            context("swift timing") {
                fit("is slower") {
//                    self.measure {
//                        _ = self.swiftdot(dc0!, dc0!)
//                        //print("testCompareDotTiming result: \(x)")
//                    }
                } // fit
            } // context("swift timing")
        } //describe(".dot")

        // MARK: .sub
        describe(".sub") {
            context("for simple data") {
                let dc0: DataCon<CDouble> = DataCon<CDouble>(elements: v0)
                let dc1: DataCon<CDouble> = DataCon<CDouble>(elements: v1)
                let v = dc0.sub(dc1)
                let w = dc1.sub(dc0)
                fit("leaves original unmodified") {
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(v0[idx]))
                        expect(dc1[idx]).to(equal(v1[idx]))
                    }
                } // fit("leaves original unmodified")
                fit("correctly computes") {
                    for idx in 0 ..< 3 {
                        expect(v[idx]).to(beCloseTo(v0[idx] - v1[idx], within: 1.0e-15))
                        expect(w[idx]).to(beCloseTo(v1[idx] - v0[idx], within: 1.0e-15))
                    }
                } // fit("correctly computes")
            } // context("for simple data")
        } //describe(".sub")

        // MARK: .distance
        describe(".distance") {
            context("for simple data") {
                let dc0: DataCon<CDouble> = DataCon<CDouble>(elements: v0)
                let dc1: DataCon<CDouble> = DataCon<CDouble>(elements: v1)
                let d00 = dc0.distance(dc0)
                let d11 = dc1.distance(dc1)
                let d01 = dc0.distance(dc1)
                let d10 = dc1.distance(dc0)
                let d01_truth = sqrt(pow(v0[0] - v1[0], 2) + pow(v0[1] - v1[1], 2) + pow(v0[2] - v1[2], 2))

                fit("correctly computes") {
                    expect(d00).to(beCloseTo(0.0, within: 1.0e-15))
                    expect(d11).to(beCloseTo(0.0, within: 1.0e-15))
                    expect(d01).to(beCloseTo(d10, within: 1.0e-15))
                    expect(d01).to(beCloseTo(d01_truth, within: 1.0e-15))
                } // fit("correctly computes

                fit("leaves original unmodified") {
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(v0[idx]))
                        expect(dc0[idx]).to(equal(v0[idx]))
                    }
                } // fit("leaves original unmodified
            } // context("for simple data")
        } // describe(".distance")
    } // override func spec()
    
    func swiftdot(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) -> CDouble
    {
        var rex: CDouble = 0.0
        let xdata = x.data
        let ydata = y.data
        for idx in 0 ..< Int(x.count) {
            rex += xdata[idx] * ydata[idx]
        }
        return rex
    }
} // class DCCDSpec: QuickSpec {


/* the following from
 https://github.com/Quick/Quick/blob/master/Documentation/en-us/SharedExamples.md
 outlines how to use a _shared example context_;
 consider for testing different matrix implementations
 
 // Swift
 
 import Quick
 import Nimble
 
 class EdibleSharedExamplesConfiguration: QuickConfiguration {
 override class func configure(_ configuration: Configuration) {
 sharedExamples("something edible") { (sharedExampleContext: @escaping SharedExampleContext) in
 it("makes dolphins happy") {
 let dolphin = Dolphin(happy: false)
 let edible = sharedExampleContext()["edible"]
 dolphin.eat(edible)
 expect(dolphin.isHappy).to(beTruthy())
 }
 }
 }
 }
 
 class MackerelSpec: QuickSpec {
 override func spec() {
 var mackerel: Mackerel!
 beforeEach {
 mackerel = Mackerel()
 }
 
 itBehavesLike("something edible") { ["edible": mackerel] }
 }
 }
 
 class CodSpec: QuickSpec {
 override func spec() {
 var cod: Cod!
 beforeEach {
 cod = Cod()
 }
 
 itBehavesLike("something edible") { ["edible": cod] }
 }
 }
 */
