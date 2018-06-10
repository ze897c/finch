//
//  extTests.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/9/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import os.log
import XCTest
@testable import finch

class stringExtensionTests: XCTestCase {
    
    /// test simple init patterns
    func testRemoveWhitespace() {
        let a: String = "The quick brown...  "
        // os_log("removed: %@", type: .info, a.removingWhitespaces())
        XCTAssertEqual(a.count - 4, a.removingWhitespaces().count)
    }
    
    func testRemoveSquareBracket() {
        print("[<555>]".removingSquareBrackets())
        XCTAssertEqual("[<555>]".removingSquareBrackets().count, 5)
        XCTAssertEqual("[<555>]".removingDelimiters().count, 3)
    }

}
