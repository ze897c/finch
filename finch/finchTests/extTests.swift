//
//  extTests.swift
//  finchTests
//
//  Created by Matthew Patterson on 6/9/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Nimble
import Quick
import os.log
import XCTest
@testable import finch


// TODO: use the approach from
//  https://github.com/Quick/Quick/blob/master/Documentation/en-us/SharedExamples.md
// to make these tests much cleaner

class FinchStringSpec: QuickSpec {
    
    override func spec() {
        // MARK: removingWhitespaces
        describe(".removingWhitespaces") {
            var a: String = ""
            var unmod: String = ""
            var truth: String = ""
            context("on simple data") {

                beforeEach {
                    a = "\tThe quick brown...  "
                    unmod = "\tThe quick brown...  "
                    truth = "Thequickbrown..."
                }
                
                fit("removes iff") {
                    let b = a.removingWhitespaces()
                    expect(b).to(equal(truth))
                } //fit("removes iff")

                fit("leaves original") {
                    _ = a.removingWhitespaces()
                    expect(a).to(equal(unmod))
                } // fit("leaves original")
                
            } // context("on simple data")
        } //describe(".removingWhitespaces")
        
        describe(".removingDelimiters") {
            var a: String = ""
            var unmod: String = ""
            var truth: String = ""
            context("on simple data") {
                beforeEach {
                    a = "[<555>]"
                    unmod = "[<555>]"
                    truth = "555"
                }

                fit("removes iff") {
                    let b = a.removingDelimiters()
                    expect(b).to(equal(truth))
                } // fit("removes iff")

                fit("leaves original") {
                    _ = a.removingDelimiters()
                    expect(a).to(equal(unmod))
                } // fit("leaves original")
            }
        } //describe(".removingDelimiters")
        
        describe(".removingSquareBrackets") {
            var a: String = ""
            var unmod: String = ""
            var truth: String = ""
            context("on simple data") {
                beforeEach {
                    a = "[<555>]"
                    unmod = "[<555>]"
                    truth = "<555>"
                }
                
                fit("removes iff") {
                    let b = a.removingSquareBrackets()
                    expect(b).to(equal(truth))
                } // fit("removes iff")
                
                fit("leaves original") {
                    _ = a.removingSquareBrackets()
                    expect(a).to(equal(unmod))
                } // fit("leaves original")
            }
        } //describe(".removingSquareBrackets")

    } // spec()
} // class FinchStringSpec: QuickSpec

