//
//  string_extension.swift
//  finch
//
//  Created by Matthew Patterson on 6/9/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

protocol InitializableFromString {
    init?<String>(_ : String)
}

// if you get to regex...
// https://developer.apple.com/documentation/foundation/nsstring/compareoptions

// WTF?
extension String {
    static let Delimiters = CharacterSet(charactersIn: "[]{}<>()")
    static let VectorSeparators = CharacterSet(charactersIn: ",;:\t").union(.whitespaces)

    func removingWhitespaces() -> String {
        return trimmingCharacters(in: .whitespaces)
    }
    func removingSquareBrackets() -> String {
        return removingAnyCharacters(of: "[]")
    }
    func removingDelimiters() -> String {
        return removingAnyCharacters(of: String.Delimiters)
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
    
    func removingAnyCharacters(of: CharacterSet) -> String {
        return self.components(separatedBy: of.inverted).joined()
    }
    
    func removingAnyCharacters(of: String) -> String {
        return removingAnyCharacters(of: CharacterSet(charactersIn: of))
        // saving the code below because I learned 2 things
        // 1. using closure in filter generally
        // 1. using 'as' to interpret as a particular protocol -- I think..
//        return self.characters.filter {
//            (x: Character) -> Bool in return (of as String).contains(x)
//            }.joined()
    }
    
    func asArray<Element: InitializableFromString>() -> [Element] {
        let string_elements: [String] = removingDelimiters().components(separatedBy: String.VectorSeparators)
        let rex: [Element] = string_elements.map {
            (x: String) -> Element in return Element(x)!
        }
        return rex
    }
}
