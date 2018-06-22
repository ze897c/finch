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
        var dc0: DataCon<CDouble> = DataCon<CDouble>()
        var dc1: DataCon<CDouble> = DataCon<CDouble>()
        var dc2: DataCon<CDouble> = DataCon<CDouble>()
        let v0: [CDouble] = [1.4, -2.2, 4.5]
        let v1: [CDouble] = [CDouble.pi, -CDouble.pi, CDouble.pi]
        
        var linspace: DataCon<CDouble>?
        
        _ = "this a long drive for someone with nothing to think about"

        // MARK: .distance
        describe(".distance") {
            context("on simple data") {
                let x: [CDouble] = [1, 0, 0]
                let y: [CDouble] = [0, 1, 0]
                let z: [CDouble] = [0, 0, 1]
                let sqrt2: CDouble = sqrt(2.0)
                beforeEach() {
                    dc0 = DataCon(elements: x)
                    dc1 = DataCon(elements: y)
                    dc2 = DataCon(elements: z)
                }
                
                fit("computes correctly on selfsame") {
                    let dxx: CDouble = dc0.distance(dc0)
                    let dyy: CDouble = dc1.distance(dc1)
                    let dzz: CDouble = dc2.distance(dc2)
                    expect(dxx).to(beCloseTo(0.0, within: CDouble.small))
                    expect(dyy).to(beCloseTo(0.0, within: CDouble.small))
                    expect(dzz).to(beCloseTo(0.0, within: CDouble.small))
                } //fit("computes correctly on selfsame")
                
                fit("computes symmetrically") {
                    let dxy: CDouble = dc0.distance(dc1)
                    let dyx: CDouble = dc1.distance(dc0)
                    let dxz: CDouble = dc0.distance(dc2)
                    let dzx: CDouble = dc2.distance(dc0)
                    let dyz: CDouble = dc1.distance(dc2)
                    let dzy: CDouble = dc2.distance(dc1)
                    expect(dxy).to(beCloseTo(dyx, within: CDouble.small))
                    expect(dxz).to(beCloseTo(dzx, within: CDouble.small))
                    expect(dzy).to(beCloseTo(dyz, within: CDouble.small))
                } //fit("computes symmetrically")
                
                fit("computes correctly") {
                    let dxy: CDouble = dc0.distance(dc1)
                    let dxz: CDouble = dc0.distance(dc2)
                    let dyz: CDouble = dc1.distance(dc2)
                    expect(dxy).to(beCloseTo(sqrt2on2, within: CDouble.small))
                    expect(dxz).to(beCloseTo(sqrt2on2, within: CDouble.small))
                    expect(dyz).to(beCloseTo(sqrt2on2, within: CDouble.small))
                } //fit("computes correctly")
                
                fit("leaves original") {
                    let _: CDouble = dc0.distance(dc1)
                    let _: CDouble = dc0.distance(dc2)
                    let _: CDouble = dc1.distance(dc2)
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(x[idx]))
                        expect(dc1[idx]).to(equal(y[idx]))
                        expect(dc2[idx]).to(equal(z[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe(".distance")
        
        // MARK: .deepcopy
        describe(".deepcopy") {
            var ecapsnil:DataCon<CDouble>?
            context("of linspace") {

                beforeEach {
                    linspace = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
                    ecapsnil = linspace!.deepcopy()
                }

                fit("has correct element count") {
                    expect(linspace!.count).to(equal(ecapsnil!.count))
                    
                } //fit("has correct element count")

                fit("elements are copied correctly") {
                    for (a, b) in zip(linspace!, ecapsnil!) {
                        expect(a).to(equal(b))
                    }
                } // fit("elements are copied correctly")

                fit("copy is deep") {
                    let truth: CDouble = ecapsnil![0]
                    linspace![0] = 27
                    expect(ecapsnil![0]).to(equal(truth))
                } // fit("copy is deep")

            } // context("of linspace")
        } //describe(".deepcopy")
        
        // MARK: .linspace
        describe(".linspace") {
            linspace = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)

            context("explicit init") {
                let N: UInt = 25
                let lins: DataCon<CDouble> = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)

                fit("has correct number of elements") {
                    expect(lins.count) == N
                } // fit("has correct number of elements")

                fit("has correct start element") {
                    expect(lins[0]) == 0
                } // fit("has correct start element")

                fit("has correct stop element") {
                    expect(lins[lins.endIndex]) == 10
                } // fit("has correct stop element")

            } // context("explicit init")
        } //describe(".linspace")

        // MARK: .diff
        describe(".diff") {
            linspace = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
            let unmod = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)

            context("on simple data") {
                let d = linspace!.diff()
                let d_truth: CDouble = 10.0/24.0

                fit("has correct number of elements") {
                    expect(d.count) == 24
                } // fit("has correct number of elements")

                fit("computes correctly") {
                    for x in d {
                        expect(x).to(beCloseTo(d_truth, within: CDouble.small))
                    }
                } // fit(""computes correctly")
                
                fit ("leaves original") {
                    for (a, b) in zip(linspace!, unmod) {
                        expect(a).to(equal(b))
                    }
                } // fit ("leaves original")

            } // context("on simple data")
        } //describe(".diff")

        // MARK: .norm
        describe(".norm") {
            context("on simple data") {
                let truth_0: CDouble = sqrt(v0[0] * v0[0] + v0[1] * v0[1] + v0[2] * v0[2])
                let truth_1: CDouble = sqrt(v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2])

                beforeEach() {
                    dc0 = DataCon<CDouble>(elements: v0)
                    dc1 = DataCon<CDouble>(elements: v1)
                }

                fit("computes correctly") {
                    let mag0 = dc0.norm
                    let mag1 = dc1.norm
                    expect(mag0).to(beCloseTo(truth_0, within: 1.0e-15))
                    expect(mag1).to(beCloseTo(truth_1, within: 1.0e-15))
                } //fit("computes correctly")

                fit("leaves original") {
                    _ = dc0.norm
                    _ = dc1.norm
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(v0[idx]))
                        expect(dc1[idx]).to(equal(v1[idx]))
                    }
                } //fit("leaves original")

            } // context("on simple data")
        } //describe(".norm")

        // MARK: .dot
        describe(".dot") {
            let truth_0: CDouble = v0[0] * v0[0] + v0[1] * v0[1] + v0[2] * v0[2]
            let truth_1: CDouble = v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2]
            context("on simple data") {
                beforeEach() {
                    dc0 = DataCon<CDouble>(elements: v0)
                    dc1 = DataCon<CDouble>(elements: v1)
                }

                fit("computes correctly") {
                    let dot0 = dc0.dot(dc0)
                    let dot1 = dc1.dot(dc1)
                    expect(dot0).to(beCloseTo(truth_0, within: 1.0e-15))
                    expect(dot1).to(beCloseTo(truth_1, within: 1.0e-15))
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = dc0.dot(dc0)
                    _ = dc1.dot(dc1)
                } // fit("leaves original")
            } // context("on simple data ")

        } //describe(".dot")

        // MARK: .sub
        describe(".sub") {
            context("for simple data") {
                beforeEach() {
                    dc0 = DataCon<CDouble>(elements: v0)
                    dc1 = DataCon<CDouble>(elements: v1)
                }
                fit("leaves original") {
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(v0[idx]))
                        expect(dc1[idx]).to(equal(v1[idx]))
                    }
                } // fit("leaves original")

                fit("computes correctly") {
                    let v = dc0.sub(dc1)
                    let w = dc1.sub(dc0)
                    for idx in 0 ..< 3 {
                        expect(v[idx]).to(beCloseTo(v0[idx] - v1[idx], within: 1.0e-15))
                        expect(w[idx]).to(beCloseTo(v1[idx] - v0[idx], within: 1.0e-15))
                    }
                } // fit("computes correctly")
            } // context("for simple data")
        } //describe(".sub")

        // MARK: .distance
        describe(".distance") {
            context("for simple data") {
                let d01_truth = sqrt(pow(v0[0] - v1[0], 2) + pow(v0[1] - v1[1], 2) + pow(v0[2] - v1[2], 2))
                beforeEach {
                    dc0 = DataCon<CDouble>(elements: v0)
                    dc1 = DataCon<CDouble>(elements: v1)
                }

                fit("computes correctly") {
                    let d00 = dc0.distance(dc0)
                    let d11 = dc1.distance(dc1)
                    let d01 = dc0.distance(dc1)
                    let d10 = dc1.distance(dc0)

                    expect(d00).to(beCloseTo(0.0, within: 1.0e-15))
                    expect(d11).to(beCloseTo(0.0, within: 1.0e-15))
                    expect(d01).to(beCloseTo(d10, within: 1.0e-15))
                    expect(d01).to(beCloseTo(d01_truth, within: 1.0e-15))
                } // fit("computes correctly"

                fit("leaves original") {
                    _ = dc0.distance(dc0)
                    _ = dc1.distance(dc1)
                    _ = dc0.distance(dc1)
                    _ = dc1.distance(dc0)
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(v0[idx]))
                        expect(dc0[idx]).to(equal(v0[idx]))
                    }
                } // fit("leaves original

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

