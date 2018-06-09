//
//  DataCon.swift
//  finch
//
//  Created by Matthew Patterson on 6/8/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate

//struct Countdown: Sequence, IteratorProtocol {
//    var count: Int
//    
//    mutating func next() -> Int? {
//        if count == 0 {
//            return nil
//        } else {
//            defer { count -= 1 }
//            return count
//        }
//    }
//}

class DataCon<Element: Numeric> // implementing class to have ARC
    :
    Equatable,
    ExpressibleByArrayLiteral,
    IteratorProtocol,
    Sequence,
    CustomStringConvertible,
    LosslessStringConvertible,
    CustomDebugStringConvertible
{

    var debugDescription: String {
        return "<DataCon: > \(self.data.description)"
    }
    
    var description: String {
        return self.data.description
    }


    
    static func == (lhs: DataCon<Element>, rhs: DataCon<Element>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for (a, b) in zip(lhs, rhs) {
            guard a == b else {
                return false
            }
        }
        return true
    }
    
    var data: ContiguousArray<Element>
    typealias ArrayLiteralElement = Element

    subscript(idx: Int) -> Element {
        return data[idx]
    }
    
    // MARK: Sequence, IteratorProtocol
    var count: Int = 0
    func next() -> Element? {
        if count == data.count {
            return nil
        } else {
            defer { count += 1 }
            return self[count]
        }
    }
    
    required init(arrayLiteral elements: Element...) {
        data = ContiguousArray<Element>(elements)
    }

    init(elements: [Element]) {
        data = ContiguousArray<Element>(elements)
    }

    required init?(_ description: String) {
        data = []
    }
}
