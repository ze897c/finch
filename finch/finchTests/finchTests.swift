//
//  finchTests.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/8/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import XCTest
import os.log
@testable import finch

// a place to debug
func square(x: Double) -> Double {
    return x * x
}

class DaCoTests: XCTestCase {

    let v0: [Double] = [1.4, -2.2, 4.5]
    let v1: [Double] = [Double.pi, -Double.pi, Double.pi]
    
    
    func testStaticCTors() {
        let N: UInt = 10
        let Ones = DataCon<Double>.Ones(N)
        let Zeros = DataCon<Double>.Zeros(N)
        XCTAssertEqual(Ones.count, 10)
        for x in Ones {
            XCTAssertEqual(x, 1)
        }
        for x in Zeros {
            XCTAssertEqual(x, 0)
        }
    }
    
    func test_linspace() {
        let N:UInt = 10
        let v = DataCon<Double>.Linspace(n: N)
        XCTAssertEqual(v[0], 0)
        XCTAssertEqual(UInt(v.count), N)
        
    }
    
    func testStringInit() {
        let dc = DataCon(arrayLiteral: v0[0], v0[1], v0[2])
        let cd: DataCon<Double> = DataCon(dc.description)!
        XCTAssertEqual(dc, cd)
    }
    
    /// test simple init patterns
    func testInit() {
        var dc: DataCon<Double> = [v0[0], v0[1], v0[2]]
        XCTAssertEqual(dc[0], v0[0])
        XCTAssertEqual(dc[1], v0[1])
        XCTAssertEqual(dc[2], v0[2])
        dc = DataCon(elements: v0)
        XCTAssertEqual(dc[0], v0[0])
        XCTAssertEqual(dc[1], v0[1])
        XCTAssertEqual(dc[2], v0[2])
    }
    
    func testDescriptors() {
        let a = v0
        print(a.description)
        print(a.description.split(separator: ","))
        for x in a.description.split(separator: ",") {
            print(x.components(separatedBy: .whitespaces).joined())
            
        }
    }
    
    func testBasicEquatable() {
        let dc = DataCon(arrayLiteral: v0[0], v0[1], v0[2])
        XCTAssertEqual(dc.count, 3)

        XCTAssertEqual(dc, dc)
        // multiple times to verify iterator c-tion/use
        XCTAssertEqual(dc, dc)
        XCTAssertEqual(dc, dc)
        XCTAssertEqual(dc, dc)

        let cd: DataCon<Double> = DataCon(elements: v0.reversed())
        XCTAssertEqual(cd.count, 3)
        XCTAssertEqual(cd, cd)
        XCTAssertNotEqual(dc, cd)
        XCTAssertNotEqual(dc, cd)
        XCTAssertNotEqual(dc, cd)
    }
    
    /// baseline tests that the *DataCon* performs as a *Sequence*
    func testMap() {
        let dc = DataCon(elements: v0)
        
        let mapped = dc.map({(x: Double) -> Double in return x * x})
        //let mapped: [Double]  = dc.map(square)
        print("mapped: \(mapped)")
        XCTAssertEqual(mapped, [v0[0] * v0[0], v0[1] * v0[1], v0[2] * v0[2]])
        XCTAssertEqual(dc, [v0[0], v0[1], v0[2]])
        for (a, b) in zip(dc, mapped) {
            // this test avoids syntactic sugar to focus on behavior of 'map'
            XCTAssertLessThanOrEqual(abs(a * a - b), Double.leastNonzeroMagnitude) // TODO: use _accuracy_ param in XCTestEqual
        }
    }
    
    /// keep *zip* working on *DaCo* as a *Sequence*, would need to do work to remake as *DaCo*
    /// but that should help odd things from happening
    func testZip() {
        let v = DataCon(elements: v0)
        let w = DataCon(elements: v1)

        for (ivw, vw) in zip(v, w).enumerated() {
            XCTAssertEqual(vw.0 * vw.1, v0[ivw] * v1[ivw])
        }
        for (ivw, vw) in zip(v, v1).enumerated() {
            XCTAssertEqual(vw.0 * vw.1, v0[ivw] * v1[ivw])
        }
    }
    
    /// assert we can make a *Sequence* from filtered *DaCo*: requires some more work to
    /// re-make as *DaCo*: test that as well
    func testFilter() {
        let v = DataCon(elements: v0)
        let w0 = v.filter {$0 < 0}
        let w1 = v0.filter {$0 < 0}
        XCTAssertEqual(w0, w1)
    }
    
    func testIsRef() {
        let a: Double = 1999.9999
        let v = DataCon(elements: v0)
        let w = v
        w[0] = a
        XCTAssertEqual(w[0], a)
        XCTAssertEqual(v[0], a)
    }
    
    func testCompactMapTo() {
        // func compactMapTo<T: DaCoEl>(f: (Element) -> T?) -> DataCon<T>? {
        
    }
    
    func testPerformanceExample() {
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
