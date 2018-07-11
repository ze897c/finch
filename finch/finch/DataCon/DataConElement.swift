//
//  DataConElement.swift
//  finch
//
//  Created by Matthew Patterson on 6/18/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

extension BinaryInteger {
    public var Zero: Self {
        get{
            return Self()
        }
    }
}

protocol SafeDivisionByIntegerProtocol {
    /// safely divide _self_ by *BinaryInteger* _y_, which is checked
    /// to be non-zero
    /// Params:
    /// y - BinaryInteger
    func safeDivide<T>(_ y: T) throws -> Self where T : BinaryInteger
}

protocol DaCoEl:
    LosslessStringConvertible,
    Numeric,
    Codable,
    SafeDivisionByIntegerProtocol
{
    /// return the zero-element
    static var Zero: Self {get}
    static var Identity: Self {get}
    init()
}
