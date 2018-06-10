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

class finchTests: XCTestCase {

    func testStringInit() {
        let a: Double = 1.4
        let b: Double = -2.0
        let c: Double = 0.3
        let dc = DataCon(arrayLiteral: a, b, c)
        let cd: DataCon<Double> = DataCon(dc.description)!
        XCTAssertEqual(dc, cd)
    }
    
    /// test simple init patterns
    func testDatConInit() {
        let a: Double = 1.4
        let b: Double = -2.0
        let c: Double = 0.3
        var dc = DataCon(arrayLiteral: a, b, c)
        XCTAssertEqual(dc[0], a)
        XCTAssertEqual(dc[1], b)
        XCTAssertEqual(dc[2], c)
        dc = DataCon(elements: [a, b, c])
        XCTAssertEqual(dc[0], a)
        XCTAssertEqual(dc[1], b)
        XCTAssertEqual(dc[2], c)
    }
    
    func testDescriptors() {
        let a = [1.2, -3.4, 6.5]
        print(a.description)
        print(a.description.split(separator: ","))
        for x in a.description.split(separator: ",") {
            print(x.components(separatedBy: .whitespaces).joined())
            
        }
    }
    
    /// baselie tests that the *DataCon* performs as a *Sequence*
    func testActAsSequenceGenegic() {
        let x: Double = 1.4
        let y: Double = -2.0
        let z: Double = 0.3
        
        let dc = DataCon(arrayLiteral: x, y, z)
        XCTAssertEqual(dc.count, 3)
        
        let cd: DataCon<Double> = [z, y, x]
        XCTAssertEqual(cd.count, 3)
        XCTAssertNotEqual(dc, cd)
        
        let mapped = dc.map({(x: Double) -> Double in return x * x})
        XCTAssertEqual(mapped, [x * x, y * y, z * z])
        XCTAssertEqual(dc, [x, y, z])
        for (a, b) in zip(dc, mapped) {
            // this test avoids syntactic sugar to focus on behavior of 'map'
            XCTAssertLessThanOrEqual(abs(a * a - b), Double.leastNonzeroMagnitude)
        }
        //let filtered: DataCon<Double> = dc.filter {$0 < 0}
        //XCTAssertEqual(filtered, [-2.0])
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
