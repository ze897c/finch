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


struct Countdown: Sequence {
    let krauthammer: Double
    
    func makeIterator() -> CountdownIterator {
        return CountdownIterator(self)
    }
}
// The makeIterator() method returns another custom type, an iterator named CountdownIterator.
// The CountdownIterator type keeps track of both the Countdown sequence that it’s iterating and the number of times it has returned a value.

struct CountdownIterator: IteratorProtocol {
    let countdown: Countdown
    var times = 0
    
    init(_ countdown: Countdown) {
        self.countdown = countdown
    }
    
    mutating func next() -> Double? {
        let nextNumber = countdown.krauthammer - Double(times)
        guard nextNumber > 0
            else { return nil }
        
        times += 1
        return nextNumber
    }
}

// testing the above, found in docs, as it seems to be the same thing I am doing with DaCo, which is bombing
class stupidTest: XCTestCase {
    func testChickens() {
        let threeTwoOne = Countdown(krauthammer: 3)
        var i: Double = 3.0
        for count in threeTwoOne {
            XCTAssertEqual(count, i)
            i -= 1
        }
        i = 3.0
        for count in threeTwoOne {
            XCTAssertEqual(count, i)
            i -= 1
        }
    }
    func testMappedChickens() {
        let threeTwoOne = Countdown(krauthammer: 3)
        let harry = threeTwoOne.map(square)
        XCTAssertEqual(harry, [9.0, 4.0, 1.0])
        let yrrah = threeTwoOne.map(square)
        XCTAssertEqual(yrrah, [9.0, 4.0, 1.0])
    }
}

class finchTests: XCTestCase {

    let v0: [Double] = [1.4, -2.2, 4.5]
    
    func testStringInit() {
        let dc = DataCon(arrayLiteral: v0[0], v0[1], v0[2])
        let cd: DataCon<Double> = DataCon(dc.description)!
        XCTAssertEqual(dc, cd)
    }
    
    /// test simple init patterns
    func testDatConInit() {
        var dc = DataCon(arrayLiteral: v0[0], v0[1], v0[2])
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
    
    /// baselie tests that the *DataCon* performs as a *Sequence*
    func testActAsSequenceGenegic() {
        let dc = DataCon(elements: v0)

        //let mapped = dc.map({(x: Double) -> Double in return x * x})
        let mapped = dc.map(square)
        print(mapped)
//        XCTAssertEqual(mapped, [x * x, y * y, z * z])
//        XCTAssertEqual(dc, [x, y, z])
//        for (a, b) in zip(dc, mapped) {
//            // this test avoids syntactic sugar to focus on behavior of 'map'
//            XCTAssertLessThanOrEqual(abs(a * a - b), Double.leastNonzeroMagnitude)
//        }
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
