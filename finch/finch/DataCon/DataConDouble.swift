//
//  DataConDouble.swift
//  finch
//
//  Created by Matthew Patterson on 6/18/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate

extension Double: DaCoEl {
    static var Identity: Double {
        get {
            return Double(1)
        }
    }
    
    func safeDivide<T>(_ y: T) throws -> Double where T : BinaryInteger {
        guard y != y.Zero else {
            throw Exceptions.DivideByZero
        }
        return self / Double(y)
    }
    
    static var Zero: Double {
        get {
            return Double()
        }
    }
}

extension DataCon where DataCon.Element == Double {

    func diff() -> DataCon<Double> {
        let N: Int = Int(count) - 1
        let newdata = UnsafeMutablePointer<Double>.allocate(capacity: N)
        // NOTE: this might be slower than naive loop...partly exercising usage
        cblas_dcopy(Int32(N), data, 1, newdata, 1)
        cblas_dscal(Int32(N), -1.0, newdata, 1)
        cblas_daxpy(Int32(N), 1.0, data + 1, 1, newdata, 1)
        return DataCon<Double>(initializedPointer: newdata, capacity: UInt(N))
    }

    func deepcopy() -> DataCon<Double> {
        // func cblas_dcopy(_ __N: Int32, _ __X: UnsafePointer<Double>!, _ __incX: Int32, _ __Y: UnsafeMutablePointer<Double>!, _ __incY: Int32)
        let rex: DataCon<Double> = DataCon(repeating: Double.Zero, count: DataCon.Index(self.count))

        let one = Int32(1)
        let N = Int32(count)
        cblas_dcopy(N, data, one, rex.data, one)
        return rex
    }

    static func BLASConstant( _ val: Double, _ n: UInt) -> DataCon<Double> {
        let rex: DataCon<Double> = DataCon(capacity: n)
        var v = Double(val)
        catlas_cset(Int32(rex.count), &v, rex.data, 1)
        return rex
    }
    
    static func Ones(count capacity: UInt) -> DataCon<Double> {
        return BLASConstant(1.0, capacity)
    }
    static func Zeros(count capacity: UInt) -> DataCon<Double> {
        return BLASConstant(0.0, capacity)
    }

    // vForce, WTF?
//    func ceil() -> DataCon<Double> {
//        let rex: DataCon<Double> = DataCon()
//        let N: UInt = UInt(self.count)
//
////        let dst: UnsafeRawPointer = UnsafeRawPointer(rex.data.first)
////
////        vvceil(rex.data.first, self.data, &N)
//
//        catlas_cset(Int32(N), 7, self.data, 1)
//
//        rex.data.withUnsafeMutableBufferPointer { dst in
//            data.withUnsafeBytes { src in
//
//                let d: UnsafeMutablePointer<Double> = dst[0]
//                vvceil(UnsafeMutablePointer<Double>(&dst[0]), src, &N)
//                //dst.copyMemory(from: src)
//            }
//        }
//
//        return rex
//    }

}
