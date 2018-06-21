//
//  DataConDoubleTest.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/18/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
// TODO: will these work?
import Nimble
import Quick
import XCTest
import os.log

@testable import finch

extension CDouble {
    var small: CDouble {
        get {
            return 1.0e-15
        }
    }
    func near(_ x: CDouble, tol: CDouble? = nil) -> Bool {
        return abs(x - self) < (tol ?? small)
    }
}


class DaCoDbTimingTests: XCTestCase {

    let v0: [CDouble] = [1.4, -2.2, 4.5]
    let v1: [CDouble] = [CDouble.pi, -CDouble.pi, CDouble.pi]
    
    var linspace: DataCon<CDouble> = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
    let msg = "this a long drive for someone with nothing to think about"
        
    func testMagnitude()
    {
        let dc0: DataCon<CDouble> = DataCon<CDouble>(elements: v0)
        let dc1: DataCon<CDouble> = DataCon<CDouble>(elements: v1)
        let truth_0: CDouble = sqrt(v0[0] * v0[0] + v0[1] * v0[1] + v0[2] * v0[2])
        let truth_1: CDouble = sqrt(v1[0] * v1[0] + v1[1] * v1[1] + v1[2] * v1[2])
        
        // .norm uses magnitude
        let mag0 = dc0.norm
        let mag1 = dc1.norm
        
        AssertNear(mag0, truth_0)
        AssertNear(mag1, truth_1)
    }

    let DotTimingN: UInt = 450000
    func testDotTiming()
    {
        let dc0: DataCon<CDouble> = DataCon<Double>.Linspace(n: DotTimingN)
        self.measure {
            _ = dc0.dot(dc0)
            //print("testDotTiming result: \(x)")
        }
    }
    
    func testCompareDotTiming()
    {
        let dc0: DataCon<CDouble> = DataCon<Double>.Linspace(n: DotTimingN)
        self.measure {
            _ = fauxdot(dc0, dc0)
            //print("testCompareDotTiming result: \(x)")
        }
    }
    
    func testDiff()
    {
        let d = linspace.diff()
        XCTAssertEqual(d.count, 24)

        let d_truth: CDouble = 10.0/24.0
        for x in d {
            AssertNear(x, d_truth)
        }
    }
    
    func testLinspace()
    {
        let N: UInt = 25
        let lins: DataCon<CDouble> = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
        XCTAssertEqual(lins.count, N)
        XCTAssertEqual(lins[0], 0)
        XCTAssertEqual(lins[lins.endIndex], 10)
    }
    
    func test_deepcopy()
    {
        let ecapsnil = linspace.deepcopy()
        XCTAssertEqual(linspace.count, ecapsnil.count)
        for (a, b) in zip(linspace, ecapsnil) {
            XCTAssertEqual(a, b)
        }
    }

    // MARK: helpers
    override func setUp()
    {
        super.setUp()
        self.linspace = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
    }
    
    override func tearDown()
    {
        super.tearDown()
    }

    func AssertNear(_ x: CDouble, _ y: CDouble, _ tol: CDouble = 1.0e-15)
    {
        XCTAssertTrue(x.near(y), "\(x) is not within \(tol) of \(y)")
    }
    
    func fauxdot(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) -> CDouble
    {
        var rex: CDouble = 0.0
        let xdata = x.data
        let ydata = y.data
        for idx in 0 ..< Int(x.count) {
            rex += xdata[idx] * ydata[idx]
        }
        return rex
    }
    
}
