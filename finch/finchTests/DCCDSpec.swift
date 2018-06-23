//
//  DCCDSpec.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/20/18.
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


class DCCDSpec: QuickSpec {

    override func spec() {
        var dc0: DataCon<CDouble> = DataCon<CDouble>()
        var dc1: DataCon<CDouble> = DataCon<CDouble>()
        var dc2: DataCon<CDouble> = DataCon<CDouble>()
        var dc3: DataCon<CDouble> = DataCon<CDouble>()
        let v0: [CDouble] = [1.4, -2.2, 4.5]
        let v1: [CDouble] = [CDouble.pi, -CDouble.pi, CDouble.pi]
        
        var linspace = DataCon<CDouble>()
        var ecapsnil = DataCon<CDouble>()
        var unmod = DataCon<CDouble>()
        var domnu = DataCon<CDouble>()
        
        let x: [CDouble] = [1, 0, 0]
        let y: [CDouble] = [0, 1, 0]
        let z: [CDouble] = [0, 0, 1]
        let xyz: [CDouble] = [1, 1, 1]
        let sqrt2: CDouble = sqrt(2.0)
        
        _ = "this a long drive for someone with nothing to think about"
        // MARK: .map with DataCon
        describe(".map with DataCon") {
            context("on simple data") {
                let f =  {(x: CDouble, y: CDouble) -> CDouble in return x * y}
                beforeEach() {
                    dc0 = DataCon(elements: v0)
                    dc1 = DataCon(elements: v1)
                }
                
                fit("computes correctly") {
                    dc2 = dc0.map(f: f, dc1)
                    expect(dc2.count).to(equal(UInt(v0.count)))
                    for idx in 0 ..< Int(v0.count) {
                        let truth = v0[idx] * v1[idx]
                        expect(dc2[idx]).to(beCloseTo(truth, within: CDouble.small))
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    dc2 = dc0.map(f: f, dc1)
                    expect(dc0.count).to(equal(UInt(v0.count)))
                    for idx in 0 ..< Int(v0.count) {
                        let truth = v0[idx]
                        expect(dc0[idx]).to(beCloseTo(truth, within: CDouble.small))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe(".map with DataCon")

        // MARK: .reversed
        describe(".reversed") {
            context("on simple data") {
                let N:Int = 44
                let lo: CDouble = -523.8
                let hi: CDouble = 1999.1919
                beforeEach() {
                    linspace = DataCon<CDouble>.Linspace(start: lo, stop: hi, n: UInt(N))
                    unmod = DataCon<CDouble>.Linspace(start: lo, stop: hi, n: UInt(N))
                }
                
                 fit("computes correctly") {
                    ecapsnil = linspace.reversed()
                    for idx in 0 ..< N {
                        expect(ecapsnil[idx]).to(beCloseTo(linspace[N - 1 - idx], within: CDouble.small))
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = linspace.reversed()
                    for idx in 0 ..< N {
                        expect(linspace[idx]).to(equal(unmod[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe(".reversed")
        
        
        // MARK: .imaxmag
        describe(".imaxmag") {
            context("on simple data") {
                let N:Int = 44
                let lo: CDouble = -523.8
                let hi: CDouble = 1999.1919
                beforeEach() {
                    linspace = DataCon<CDouble>.Linspace(start: lo, stop: hi, n: UInt(N))
                    unmod = DataCon<CDouble>.Linspace(start: lo, stop: hi, n: UInt(N))
                    ecapsnil = linspace.reversed()
                    domnu = unmod.reversed()
                }

                fit("computes correctly") {
                    let a: UInt = linspace.imaxmag()
                    let b: UInt = ecapsnil.imaxmag()
                    expect(a).to(equal(UInt(N - 1)))
                    expect(b).to(equal(0))
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = linspace.imaxmag()
                    _ = ecapsnil.imaxmag()
                    for idx in 0 ..< N {
                        expect(linspace[idx]).to(equal(unmod[idx]))
                        expect(ecapsnil[idx]).to(equal(domnu[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe(".imaxmag")
        
        // MARK: .minmax
        describe(".minmax") {
            context("on simple data") {
                let big: CDouble = 17.9
                let elms: [CDouble] = [-big, 2, -3, 0, 5, big]
                beforeEach() {
                    dc0 = DataCon(elements: elms)
                    dc1 = DataCon(elements: [big, 2, -3, 0, 5, -big])
                    dc2 = DataCon(elements: [3, -2, -big, big, 5, 9])
                    dc3 = DataCon(elements: [-3, 2, big, -big, 5, 9])
                }
                
                fit("computes correctly") {
                    let mm0 = dc0.minmax()
                    let mm1 = dc1.minmax()
                    let mm2 = dc2.minmax()
                    let mm3 = dc3.minmax()
                    expect(mm0.imin) == 0
                    expect(mm0.min) == -big
                    expect(mm0.imax) == 5
                    expect(mm0.max) == big
                    
                    expect(mm1.imin) == 5
                    expect(mm1.min) == -big
                    expect(mm1.imax) == 0
                    expect(mm1.max) == big
                    
                    expect(mm2.imin) == 2
                    expect(mm2.min) == -big
                    expect(mm2.imax) == 3
                    expect(mm2.max) == big
                    
                    expect(mm3.imin) == 3
                    expect(mm3.min) == -big
                    expect(mm3.imax) == 2
                    expect(mm3.max) == big
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = dc0.minmax()
                    for (a, b) in zip(dc0, elms) {
                        expect(a) == b
                    }
                } //fit("leaves original")

                fit("sugared versions work") {
                    expect(dc0.min()).to(equal(-big))
                    expect(dc0.imin()).to(equal(0))
                    expect(dc0.max()).to(equal(big))
                    expect(dc0.imax()).to(equal(5))
                }

            } // context("on simple data")
        } //describe(".minmax")

        // MARK: .scale
        describe(".scale") {
            context("on simple data") {
                let a = CDouble.pi
                let b:CDouble = -8.183
                let c: CDouble = 19999.999162

                beforeEach() {
                    dc0 = DataCon(elements: x)
                    dc1 = DataCon(elements: y)
                    dc2 = DataCon(elements: z)
                    dc3 = DataCon(elements: xyz)
                }
                
                fit("computes correctly") {
                    let dc0sa = dc0.scale(a)
                    let dc1sb = dc1.scale(b)
                    let dc2sc = dc2.scale(c)
                    let dc3sa = dc3.scale(a)
                    for idx in 0 ..< 3 {
                        expect(dc0sa[idx]).to(beCloseTo(a * x[idx], within: CDouble.small))
                        expect(dc1sb[idx]).to(beCloseTo(b * y[idx], within: CDouble.small))
                        expect(dc2sc[idx]).to(beCloseTo(c * z[idx], within: CDouble.small))
                        expect(dc3sa[idx]).to(beCloseTo(a * xyz[idx], within: CDouble.small))
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = dc0.scale(a)
                    _ = dc1.scale(b)
                    _ = dc2.scale(c)
                    _ = dc3.scale(a)
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(x[idx]))
                        expect(dc1[idx]).to(equal(y[idx]))
                        expect(dc2[idx]).to(equal(z[idx]))
                        expect(dc3[idx]).to(equal(xyz[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe(".scale")

        // MARK: .negate
        describe(".negate") {
            context("on simple data") {

                beforeEach() {
                    dc0 = DataCon(elements: x)
                    dc1 = DataCon(elements: y)
                    dc2 = DataCon(elements: z)
                }
                
                fit("computes correctly") {
                    let ndc0 = dc0.negate()
                    let ndc1 = dc1.negate()
                    let ndc2 = dc2.negate()

                    for idx in 0 ..< 3 {
                        expect(ndc0[idx]).to(equal(-1 * x[idx]))
                        expect(ndc1[idx]).to(equal(-1 * y[idx]))
                        expect(ndc2[idx]).to(equal(-1 * z[idx]))
                    }
                } //fit("computes correctly")
                
                fit("leaves original") {
                    _ = dc0.negate()
                    _ = dc1.negate()
                    _ = dc2.negate()
                    for idx in 0 ..< 3 {
                        expect(dc0[idx]).to(equal(x[idx]))
                        expect(dc1[idx]).to(equal(y[idx]))
                        expect(dc2[idx]).to(equal(z[idx]))
                    }
                } //fit("leaves original")
                
            } // context("on simple data")
        } //describe(".negate")
        
        // MARK: .distance
        describe(".distance") {
            context("on simple data") {

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
                    expect(dxy).to(beCloseTo(sqrt2, within: CDouble.small))
                    expect(dxz).to(beCloseTo(sqrt2, within: CDouble.small))
                    expect(dyz).to(beCloseTo(sqrt2, within: CDouble.small))
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
            context("of linspace") {
                let N:Int = 4444
                let lo: CDouble = -523.8
                let hi: CDouble = 1999.1919
                beforeEach() {
                    linspace = DataCon<CDouble>.Linspace(start: lo, stop: hi, n: UInt(N))
                    unmod = DataCon<CDouble>.Linspace(start: lo, stop: hi, n: UInt(N))
                }

                fit("has correct element count") {
                    ecapsnil = linspace.deepcopy()
                    expect(linspace.count).to(equal(UInt(N)))
                } //fit("has correct element count")

                fit("elements are copied correctly") {
                    ecapsnil = linspace.deepcopy()
                    for (a, b) in zip(linspace, ecapsnil) {
                        expect(a).to(equal(b))
                    }
                } // fit("elements are copied correctly")

                fit("copy is deep") {
                    let truth: CDouble = ecapsnil[0]
                    linspace[0] = 27
                    expect(ecapsnil[0]).to(equal(truth))
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

            context("on simple data") {
                let d = linspace.diff()
                let d_truth: CDouble = 10.0/24.0

                beforeEach() {
                    linspace = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
                    unmod = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
                }
                
                fit("has correct number of elements") {
                    expect(d.count) == 24
                } // fit("has correct number of elements")

                fit("computes correctly") {
                    for x in d {
                        expect(x).to(beCloseTo(d_truth, within: CDouble.small))
                    }
                } // fit(""computes correctly")
                
                fit ("leaves original") {
                    for (a, b) in zip(linspace, unmod) {
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

