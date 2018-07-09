//
//  SimpleProtocols.swift
//  finch
//
//  Created by Matthew Patterson on 7/9/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation

protocol IDProtocol {
    var id:String {get}
}
extension IDProtocol {
    var id:String {
        get {
            let addr = Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque()
            return addr.debugDescription
        }
    }
}
