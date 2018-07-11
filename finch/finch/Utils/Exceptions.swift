//
//  Exceptions.swift
//  finch
//
//  Created by Matthew Patterson on 6/11/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

enum Exceptions : Error {
    case Unknown(_ msg: String)
    case OutOfBoundsException
    case DivideByZero
    case ShapeMismatch
    case TypeNotEncodeable
}
