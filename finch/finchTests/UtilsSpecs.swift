//
//  UtilsSpecs.swift
//  finchTests
//
//  Created by Matthew Patterson on 7/9/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import finch

class MyClass: IDProtocol {}
struct MyStruct: IDProtocol {}

class IDProtocolSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: id protocol
        describe("id protocol") {
            // the -- probably stupid -- idea here is to be able to find out
            // if an instance is duplicated when dumping to JSON
            context("on simple data") {

                fit("returns usable") {
                    let myclass = MyClass()
                    let ssalcym = myclass
                    let mystruct = MyStruct()
                    let tcurtsym = mystruct

                    expect(myclass.id).to(beAKindOf(String.self))
                    expect(mystruct.id).to(beAKindOf(String.self))
                    expect(ssalcym.id).to(beAKindOf(String.self))
                    expect(ssalcym.id).to(equal(myclass.id))
                    expect(tcurtsym.id).toNot(equal(mystruct.id))
                } //fit("returns usable")

            } // context("on simple data")
        } //describe("<#desc#>")
    } // override func spec()
} // class MatrixMemViewSpec: QuickSpec
