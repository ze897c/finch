//
//  chickenTests.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/10/18.
//  Copyright © 2018 octeps. All rights reserved.
//
import XCTest
import Foundation


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
