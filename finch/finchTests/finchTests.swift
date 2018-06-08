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

    func testDatConArrayLiteralInit() {
        let a: Double = 1
        let b: Double = -2
        let c: Double = 3
        let dc = DataCon(arrayLiteral: a, b, c)
        XCTAssertEqual(dc[0], a)
        
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
