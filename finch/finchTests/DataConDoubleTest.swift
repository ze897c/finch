//
//  DataConDoubleTest.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/18/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import XCTest
import os.log
@testable import finch

extension Double {
    var small: Double {
        get {
            return 1.0e-15
        }
    }
    func near(_ x: Double, tol: Double? = nil) -> Bool {
        return abs(x - self) < (tol ?? small)
    }
}


class DaCoDbTests: XCTestCase {

    let v0: [Double] = [1.4, -2.2, 4.5]
    let v1: [Double] = [Double.pi, -Double.pi, Double.pi]
    var linspace: DataCon<Double> = DataCon<Double>.Linspace(start: 0, stop: 10, n: 25)
    let msg = "this a long drive for someone with nothing to think about"
    
    func testDiff() {
        let d = linspace.diff()
        XCTAssertEqual(d.count, 24)

        let d_truth: Double = 10.0/24.0
        for x in d {
            XCTAssertTrue(x.near(d_truth), "\(x) is not near \(d_truth)")
        }
    }
    
    func testLinspace() {
        let N: UInt = 25
        let lins: DataCon<Double> = DataCon<Double>.Linspace(start: 0, stop: 10, n: 25)
        XCTAssertEqual(lins.count, N)
        XCTAssertEqual(lins[0], 0)
        XCTAssertEqual(lins[lins.endIndex], 10)
    }
    
    func test_deepcopy() {
        let ecapsnil = linspace.deepcopy()
        XCTAssertEqual(linspace.count, ecapsnil.count)
        for (a, b) in zip(linspace, ecapsnil) {
            XCTAssertEqual(a, b)
        }
    }

    override func setUp() {
        super.setUp()
        self.linspace = DataCon<Double>.Linspace(start: 0, stop: 10, n: 25)
    }
    
    override func tearDown() {
        super.tearDown()
    }

}
