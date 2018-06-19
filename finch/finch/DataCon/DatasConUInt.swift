//
//  DatasConUInt.swift
//  finch
//
//  Created by Matthew Patterson on 6/19/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

extension UInt: DaCoEl {
    static var Identity: UInt {
        get {
            return UInt(1)
        }
    }
    
    func safeDivide<T>(_ y: T) throws -> UInt where T : BinaryInteger {
        guard y != y.Zero else {
            throw Exceptions.DivideByZero
        }
        return self / UInt(y)
    }
    
    static var Zero: UInt {
        get {
            return UInt()
        }
    }
}
