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
    static var small: CDouble {
        get {
            return 1.0e-15
        }
    }
    func near(_ x: CDouble, tol: CDouble? = nil) -> Bool {
        return abs(x - self) < (tol ?? CDouble.small)
    }
}


class DaCoDbTimingTests: XCTestCase {

    let v0: [CDouble] = [1.4, -2.2, 4.5]
    let v1: [CDouble] = [CDouble.pi, -CDouble.pi, CDouble.pi]
    
    var linspace: DataCon<CDouble> = DataCon<CDouble>.Linspace(start: 0, stop: 10, n: 25)
    let msg = "this a long drive for someone with nothing to think about"

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
