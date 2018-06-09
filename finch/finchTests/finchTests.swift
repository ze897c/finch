//
//  finchTests.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/8/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import XCTest
@testable import finch

class finchTests: XCTestCase {

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
        let a: Double = 1.4
        let b: Double = -2.0
        let c: Double = 0.3
        let dc = DataCon(arrayLiteral: a, b, c)
        let mapped = dc.map({(x: Double) -> Double in return x * x})
        XCTAssertEqual(dc, [a, b, c])
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
