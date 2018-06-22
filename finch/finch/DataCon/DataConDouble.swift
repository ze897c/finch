//
//  DataConDouble.swift
//  finch
//
//  Created by Matthew Patterson on 6/18/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate

extension CDouble: DaCoEl {
    static var Identity: Double {
        get {
            return CDouble(1)
        }
    }
    
    func safeDivide<T>(_ y: T) throws -> Double where T : BinaryInteger {
        guard y != y.Zero else {
            throw Exceptions.DivideByZero
        }
        return self / CDouble(y)
    }
    
    static var Zero: CDouble {
        get {
            return CDouble()
        }
    }
}

extension DataCon where DataCon.Element == CDouble {

    // MARK: magic
    func sub_inplace(_ v: DataCon<CDouble>, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil) -> DataCon<Double>
    {
        let N = n ?? count
        let rex = DataCon<CDouble>(capacity: N)
        axpby(a: 1.0, v, b: -1.0, n: N, stride: stride, offset: offset, vstride: vstride, voffset: voffset)
        return rex
    }
    
    func sub(_ v: DataCon<CDouble>, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil) -> DataCon<Double>
    {
        let N = n ?? count
        let rex = v.deepcopy()
        axpby(a: 1.0, rex, b: -1.0, n: N, stride: stride, offset: offset, vstride: vstride, voffset: voffset)
        return rex
    }
    
    // MARK: cblas implemented

    // func catlas_daxpby(_ __N: Int32, _ __alpha: Double, _ __X: UnsafePointer<Double>!, _ __incX: Int32, _ __beta: Double, _ __Y: UnsafeMutablePointer<Double>!, _ __incY: Int32)
    /// Computes the sum of two vectors, scaling each one separately
    /// modifies input *DataCon*
    /// Parameters -
    ///
    /// a * this + b * that -> that
    func axpby(a: Double, _ v: DataCon<CDouble>, b: Double, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil)
    {
        let num = Int32(n ?? count)
        let aptr = data + Int(offset ?? 0)
        let astr = Int32(stride ?? 1)
        let bptr = v.data + Int(voffset ?? 0)
        let bstr = Int32(vstride ?? 1)
        catlas_daxpby(num, CDouble(a), aptr, astr, CDouble(b), bptr, bstr)
    }
    /// a * this + b * that -> this
    func axpby_inplace(a: Double, _ v: DataCon<CDouble>, b: Double, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil)
    {
        let num = Int32(n ?? count)
        let aptr = v.data + Int(voffset ?? 0)
        let astr = Int32(vstride ?? 1)
        let bptr = data + Int(offset ?? 0)
        let bstr = Int32(stride ?? 1)
        catlas_daxpby(num, CDouble(a), aptr, astr, CDouble(b), bptr, bstr)
    }
    
    func distance(_ v: DataCon<CDouble>, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil) -> CDouble
    {
        return sub(v).norm
    }
    
    func negate_inplace(n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil)
    {
        cblas_dscal(Int32(count), -1.0, data + Int(offset ?? 0), Int32(stride ?? 1))
    }
    
    func negate(n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil) -> DataCon<CDouble>
    {
        let rex = deepcopy()
        cblas_dscal(Int32(count), -1.0, rex.data + Int(offset ?? 0), Int32(stride ?? 1))
        return rex
    }
    
    func scale_inplace(_ alpha: Double, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil)
    {
        cblas_dscal(Int32(n ?? count), CDouble(alpha), data + Int(offset ?? 0), Int32(stride ?? 1))
    }
    
    func scale(_ alpha: Double, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil) -> DataCon<CDouble>
    {
        let rex = deepcopy()
        rex.scale_inplace(alpha, n: n, stride: stride, offset: offset)
        return rex
    }

    var norm: CDouble { get { return magnitude() } }

    func magnitude(n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil) -> CDouble {
        let num = Int32(n ?? count)
        let ptr = data + Int(offset ?? 0)
        let str = Int32(stride ?? 1)
        return sqrt(cblas_ddot(num, ptr, str, ptr, str))
    }
    
    func dot(_ v: DataCon<CDouble>, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil) -> CDouble
    {
        let num = Int32(n ?? count)
        let xptr = data + Int(offset ?? 0)
        let xstr = Int32(stride ?? 1)
        let vptr = data + Int(voffset ?? 0)
        let vstr = Int32(vstride ?? 1)
        return cblas_ddot(num, xptr, xstr, vptr, vstr)
    }
    
    func diff() -> DataCon<CDouble>
    {
        let N = Int32(count) - 1
        let newdata = UnsafeMutablePointer<CDouble>.allocate(capacity: Int(N))
        // NOTE: this might be slower than naive loop...partly exercising usage
        cblas_dcopy(N, data, 1, newdata, 1)
        // TODO: replace with daxpby
        cblas_dscal(N, -1.0, newdata, 1)
        cblas_daxpy(N, 1.0, data + 1, 1, newdata, 1)
        return DataCon<CDouble>(initializedPointer: newdata, capacity: UInt(N))
    }

    func deepcopy() -> DataCon<CDouble>
    {
        // func cblas_dcopy(_ __N: Int32, _ __X: UnsafePointer<Double>!, _ __incX: Int32, _ __Y: UnsafeMutablePointer<Double>!, _ __incY: Int32)
        let rex: DataCon<CDouble> = DataCon(repeating: CDouble.Zero, count: DataCon.Index(self.count))

        let one = Int32(1)
        let N = Int32(count)
        cblas_dcopy(N, data, one, rex.data, one)
        return rex
    }

    /// return container filled with given *Double* value
    /// Params -
    /// val: Double
    /// count: UInt
    static func BLASConstant( _ val: CDouble, _ n: UInt) -> DataCon<Double>
    {
        let rex: DataCon<CDouble> = DataCon(capacity: n)
        var v = CDouble(val)
        catlas_cset(Int32(rex.count), &v, rex.data, 1)
        return rex
    }
    
    /// return container filled with 1.0s
    /// Params -
    /// count: UInt
    static func Ones(count capacity: UInt) -> DataCon<Double>
    {
        return BLASConstant(1.0, capacity)
    }

    /// return container filled with 0.0s
    /// Params -
    /// count: UInt
    static func Zeros(count capacity: UInt) -> DataCon<Double>
    {
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
