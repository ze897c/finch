//
//  extTests.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/9/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

import XCTest
@testable import finch

class stringExtensionTests: XCTestCase {
    
    /// test simple init patterns
    func testRemoveWhitespace() {
        let a: String = "The quick brown...  "
        XCTAssertEqual(a.count - 4, a.removingWhitespaces().count)
    }
    
    func testRemoveSquareBracket() {
        let r = Double("3.12")
        XCTAssertEqual(r, 3.12)
        
        let sed = CharacterSet("[]{}")
        
        "[<555>]".trimmingCharacters(in: <#T##CharacterSet#>)(in: "[", with: ""))
    }

}
