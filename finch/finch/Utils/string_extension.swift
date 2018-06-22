//
//  string_extension.swift
//  finch
//
//  Created by Matthew Patterson on 6/9/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation


//public protocol InitializableFromString {
//    init?<String>(_ : String)
//}
//
//extension Double: InitializableFromString {
//    public init?<String>(_: String) {
//        super.init(_)
//    }
//}

// if you get to regex...
// https://developer.apple.com/documentation/foundation/nsstring/compareoptions

// WTF?
public extension String {
    static let Delimiters = CharacterSet(charactersIn: "[]{}<>()")
    static let VectorSeparators = CharacterSet(charactersIn: ",;:\t").union(.whitespaces)

    public func removingWhitespaces() -> String {
        return removingAnyCharacters(inCharacterSet: .whitespaces)
    }

    func removingSquareBrackets() -> String {
        return removingAnyCharacters(of: "[]")
    }

    func removingDelimiters() -> String {
        return removingAnyCharacters(inCharacterSet: String.Delimiters)
    }

    /// return a String: replacing any of the characters in _of_ string with _with_
    /// - Parameters:
    ///   - inString: a String, all characters of which are replaced
    ///   - with: a String used to replace matching characters
    func replacingAnyCharacters(inString: String, with: String) -> String {
        return self.map {
            return inString.contains($0) ? with: String($0)
        }.joined()
    }
    
    func removingAnyCharacters(inCharacterSet: CharacterSet) -> String {
        return self.components(separatedBy: inCharacterSet).joined()
    }
    
    func removingAnyCharacters(of: String) -> String {
        return removingAnyCharacters(inCharacterSet: CharacterSet(charactersIn: of))
        // saving the code below because I learned 2 things
        // 1. using closure in filter generally
        // 1. using 'as' to interpret as a particular protocol -- I think..
//        return self.characters.filter {
//            (x: Character) -> Bool in return (of as String).contains(x)
//            }.joined()
    }

}

// TODO: move
public func asDoubleArray(_ string: String) -> [Double] {
    let elements: [String] = string.removingDelimiters().components(separatedBy: String.VectorSeparators)
    return elements.filter{(x: String)->Bool in return x.count > 0}.map{(x: String)->Double in return Double(x)!}
}

