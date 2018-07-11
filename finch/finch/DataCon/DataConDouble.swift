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
//    func cblas_dasum(Int32, UnsafePointer<Double>!, Int32) -> Double
//    Computes the sum of the absolute values of elements in a vector (double-precision).

    // MARK: min/max
    
    /// return index of minimum value
    /// NOTE: imax is faster
    func imin(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> UInt {
        let mm = minmax(n, offset, stride)
        return mm.imin
    }
    
    /// return minimum value
    func min(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> CDouble {
        let mm = minmax(n, offset, stride)
        return mm.min
    }
    
    /// return index of minimum value
    /// NOTE: imax is faster
    func imax(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> UInt {
        let mm = minmax(n, offset, stride)
        return mm.imax
    }
    
    /// return minimum value
    func max(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> CDouble {
        let mm = minmax(n, offset, stride)
        return mm.max
    }
    
    /// return index/element pairs for min & max
    func minmax(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> (imin: UInt, min: CDouble, imax: UInt, max: CDouble) {

        let num = n ?? count
        let xstart = offset ?? 0
        let xstr = stride ?? 1
        
        var rex: (imin: UInt, min: CDouble, imax: UInt, max: CDouble) = (0, data[0], 0, data[0])
        for idx in 1 ..< num {
            let xdx = xstart + idx * xstr
            let x = data[Int(xdx)]
            if x < rex.min {
                rex.min = x
                rex.imin = idx
                continue
            }
            if rex.max < x {
                rex.max = x
                rex.imax = idx
            }
        }
        return rex
    }
    
    /// return index of element with maximum absolute value
    func imaxmag(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> UInt {
        return UInt(cblas_idamax(Int32(n ?? count), data + Int(offset ?? 0), Int32(stride ?? 1)))
    }
    
    /// return element with maximum absolute value
    func maxmag(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> CDouble {
        return data[Int(imaxmag(n, offset, stride))]
    }
    
    // MARK: mul
    /// x * y -> x
    /// where _x_ is the instance
    static func *=(_ x: DataCon<CDouble>, _ y: CDouble) {
        return x.scale_inplace(y)
    }
    static func *=(_ x: CDouble, _ y: DataCon<CDouble>) {
        return y.scale_inplace(x)
    }
    
    /// Return x * y
    /// where _x_ is the instance & operation is elementwise
    static func *(_ x: DataCon<CDouble>, _ y: CDouble) -> DataCon<CDouble> {
        return x.scale(y)
    }
    static func *(_ x: CDouble, _ y:DataCon<CDouble>) -> DataCon<CDouble> {
        return y.scale(x)
    }
    
    /// x * y -> x
    /// where _x_ is the instance
    static func *=(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) {
        return x.mul_inplace(y)
    }
    
    /// Return x * y
    /// where _x_ is the instance & operation is elementwise
    static func *(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) -> DataCon<CDouble> {
        return x.mul(y)
    }
    
    /// x * y -> x
    /// where _x_ is the instance
    /// - Parameters:
    ///   - y: CDouble
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func mul_inplace(_ y: CDouble, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil)
    {
        let num = Int(n ?? count)
        let xstart = Int(xoffset ?? 0)
        let xstr = Int(xstride ?? 1)
        for idx in 0 ..< num {
            let xdx = xstart + idx * xstr
            data[xdx] *= y
        }
    }
    
    /// Return: x * y
    /// where _x_ is the instance & operation is elementwise
    /// options for fine control of offset and stride
    /// - Parameters:
    ///   - y: CDouble
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func mul(_ y: CDouble, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil) -> DataCon<CDouble>
    {
        let num = Int(n ?? count)
        let xstart = Int(xoffset ?? 0)
        let xstr = Int(xstride ?? 1)
        let rex = DataCon<CDouble>(capacity: UInt(num))
        for idx in 0 ..< num {
            let xdx = xstart + idx * xstr
            rex[xdx] = data[xdx] * y
        }
        return rex
    }
    
    /// x * y -> x
    /// where _x_ is the instance & operation is elementwise
    /// - Parameters:
    ///   - y: DataCon<CDouble>: _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func mul_inplace(_ y: DataCon<CDouble>, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil)
    {
        let num = Int(n ?? count)
        let (xstart, ystart) = (Int(xoffset ?? 0), Int(yoffset ?? 0))
        let (xstr, ystr) = (Int(xstride ?? 1), Int(ystride ?? 1))
        for idx in 0 ..< num {
            let (xdx, ydx) = (xstart + idx * xstr, ystart + idx * ystr)
            data[xdx] *= y[ydx]
        }
    }
    
    /// Return: x * y
    /// where _x_ is the instance & operation is elementwise
    /// options for fine control of offset and stride
    /// - Parameters:
    ///   - y: DataCon<CDouble>: _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func mul(_ y: DataCon<CDouble>, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil) -> DataCon<CDouble>
    {
        let num = Int(n ?? count)
        let (xstart, ystart) = (Int(xoffset ?? 0), Int(yoffset ?? 0))
        let (xstr, ystr) = (Int(xstride ?? 1), Int(ystride ?? 1))
        let rex = DataCon<CDouble>(capacity: UInt(num))
        for idx in 0 ..< num {
            let (xdx, ydx) = (xstart + idx * xstr, ystart + idx * ystr)
            rex[xdx] = data[xdx] * y[ydx]
        }
        return rex
    }

    // useful?
    //func vU512Divide(_ numerator: UnsafePointer<vU512>, _ divisor: UnsafePointer<vU512>, _ result: UnsafeMutablePointer<vU512>, _ remainder: UnsafeMutablePointer<vU512>?)
    
    // MARK: map // TODO: add tests
    // TODO: generic DataCon has mapTo ... which is a map_inplace...downselect
    
    /// f(x, y) -> x
    /// where _x_ is the instance
    /// - Parameters:
    ///   - y: DataCon<CDouble>: _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    ///   - f: (CDouble, CDouble) -> CDouble; function to map
    func map_inplace(_ f: (CDouble, CDouble) -> CDouble, _ y: DataCon<CDouble>, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil)
    {
        let num = Int(n ?? count)
        let (xstart, ystart) = (Int(xoffset ?? 0), Int(yoffset ?? 0))
        let (xstr, ystr) = (Int(xstride ?? 1), Int(ystride ?? 1))
        for idx in 0 ..< num {
            let (xdx, ydx) = (xstart + idx * xstr, ystart + idx * ystr)
            data[xdx] = f(data[xdx], y[ydx])
        }
    }

    /// Return: f(x, y)
    /// where _x_ is the instance
    /// options for fine control of offset and stride
    /// uses .axpby
    /// - Parameters:
    ///   - y: DataCon<CDouble>: _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    ///   - f: (CDouble, CDouble) -> CDouble; function to map
    func map(f: (CDouble, CDouble) -> CDouble, _ y: DataCon<CDouble>, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil) -> DataCon<CDouble>
    {
        let num = Int(n ?? count)
        let (xstart, ystart) = (Int(xoffset ?? 0), Int(yoffset ?? 0))
        let (xstr, ystr) = (Int(xstride ?? 1), Int(ystride ?? 1))
        let rex = DataCon<CDouble>(capacity: UInt(num))
        for idx in 0 ..< num {
            let (xdx, ydx) = (xstart + idx * xstr, ystart + idx * ystr)
            rex[xdx] = f(data[xdx], y[ydx])
        }
        return rex
    }

    /// f(x) -> x
    /// where _x_ is the instance
    /// - Parameters:
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - f: (CDouble) -> CDouble; function to map
    func flatmap_inplace(_ f: (CDouble) -> CDouble, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil)
    {
        let num = Int(n ?? count)
        let xstart = Int(xoffset ?? 0)
        let xstr = Int(xstride ?? 1)
        for idx in 0 ..< num {
            let xdx = xstart + idx * xstr
            data[xdx] = f(data[xdx])
        }
    }
    
    /// Return: f(x)
    /// where _x_ is the instance
    /// options for fine control of offset and stride
    /// - Parameters:
    ///   - y: DataCon<CDouble>: _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - f: (CDouble) -> CDouble; function to map
    func map(f: (CDouble) -> CDouble, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil) -> DataCon<CDouble>
    {
        let num = Int(n ?? count)
        let xstart = Int(xoffset ?? 0)
        let xstr = Int(xstride ?? 1)
        let rex = DataCon<CDouble>(capacity: UInt(num))
        for idx in 0 ..< num {
            let xdx = xstart + idx * xstr
            rex[xdx] = f(data[xdx])
        }
        return rex
    }

    // MARK: add

    /// x + y -> x
    /// where _x_ is the instance
    static func +=(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) {
        return x.add_inplace(y)
    }
    
    /// Return x + y
    /// where _x_ is the instance
    static func +(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) -> DataCon<CDouble> {
        return x.add(y)
    }
    
    /// x + y -> x
    /// where _x_ is the instance
    func add_inplace(_ y: DataCon<CDouble>, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil)
    {
        let N = n ?? count
        axpby_inplace(1.0, y, 1.0, n: N, xstride: xstride, xoffset: xoffset, ystride: ystride, yoffset: yoffset)
    }
    
    /// Return: x + y
    /// where _x_ is the instance
    /// options for fine control of offset and stride
    /// uses .axpby
    /// - Parameters:
    ///   - y: DataCon<CDouble>: _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func add(_ y: DataCon<CDouble>, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil) -> DataCon<Double>
    {
        let N = n ?? count
        let rex = y.deepcopy()
        axpby(1.0, rex, 1.0, n: N, xstride: xstride, xoffset: xoffset, ystride: ystride, yoffset: yoffset)
        return rex
    }
    
    // MARK: sub
    
    /// x - y -> x
    /// where _x_ is the instance
    static func -=(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) {
        return x.sub_inplace(y)
    }
    
    /// Return x - y
    /// where _x_ is the instance
    static func -(_ x: DataCon<CDouble>, _ y: DataCon<CDouble>) -> DataCon<CDouble> {
        return x.sub(y)
    }
    
    /// x - y -> x
    /// where _x_ is the instance
    func sub_inplace(_ v: DataCon<CDouble>, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil)
    {
        let N = n ?? count
        axpby_inplace(1.0, v, -1.0, n: N, xstride: stride, xoffset: offset, ystride: vstride, yoffset: voffset)
    }
    
    /// Return: x - y
    /// where _x_ is the instance
    /// options for fine control of offset and stride
    /// uses .axpby
    /// - Parameters:
    ///   - y: DataCon<CDouble>: _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func sub(_ y: DataCon<CDouble>, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil) -> DataCon<Double>
    {
        let N = n ?? count
        let rex = y.deepcopy()
        axpby(1.0, rex, -1.0, n: N, xstride: xstride, xoffset: xoffset, ystride: ystride, yoffset: yoffset)
        return rex
    }

    // MARK: axpby(s)
    
    /// alpha * x + b * y -> y
    /// where _x_ is the instance
    /// uses *catlas_daxpby*
    /// - Parameters:
    ///   - alpha: scalar for _x_
    ///   - y: DataCon<CDouble>: _y_
    ///   - beta: scalar for _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func axpby(_ alpha: Double, _ y: DataCon<CDouble>, _ beta: Double, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil)
    {
        let num = Int32(n ?? count)
        let aptr = data + Int(xoffset ?? 0)
        let astr = Int32(xstride ?? 1)
        let bptr = y.data + Int(yoffset ?? 0)
        let bstr = Int32(ystride ?? 1)
        catlas_daxpby(num, CDouble(alpha), aptr, astr, CDouble(beta), bptr, bstr)
    }

    /// alpha * x + beta * y -> x
    /// where _x_ is the instance
    /// uses *catlas_daxpby*
    /// - Parameters:
    ///   - alpha: scalar for _x_
    ///   - y: DataCon<CDouble>: _y_
    ///   - beta: scalar for _y_
    ///   - n: UInt; how many elements
    ///   - xstride: UInt; stide for _x_
    ///   - xoffset: UInt; offset for _x_
    ///   - ystride: UInt; stide for _y_
    ///   - yoffset: UInt; offset for _y_
    func axpby_inplace(_ alpha: Double, _ y: DataCon<CDouble>, _ beta: Double, n: UInt? = nil, xstride: UInt? = nil, xoffset: UInt? = nil, ystride: UInt? = nil, yoffset: UInt? = nil)
    {
        let num = Int32(n ?? count)
        let aptr = y.data + Int(yoffset ?? 0)
        let astr = Int32(ystride ?? 1)
        let bptr = data + Int(xoffset ?? 0)
        let bstr = Int32(xstride ?? 1)
        // yes (alpha, beta) switches up
        catlas_daxpby(num, CDouble(beta), aptr, astr, CDouble(alpha), bptr, bstr)
    }
    
    func distance(_ v: DataCon<CDouble>, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil, vstride: UInt? = nil, voffset: UInt? = nil) -> CDouble
    {
        return sub(v).norm
    }
    
    // MARK: negates
    
    static prefix func - (_ x: DataCon<CDouble>) -> DataCon<CDouble> {
        return x.negate()
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
    
    // MARK: scale
    
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

    // MARK: norm
    
    var norm: CDouble { get { return magnitude() } }

    func magnitude(n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil) -> CDouble {
        let num = Int32(n ?? count)
        let ptr = data + Int(offset ?? 0)
        let str = Int32(stride ?? 1)
        return cblas_dnrm2(num, ptr, str)
        // return sqrt(cblas_ddot(num, ptr, str, ptr, str))
    }
    
    // MARK: math
    
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

    func reversed(_ n: UInt? = nil, _ offset: UInt? = nil, _ stride: UInt? = nil) -> DataCon<CDouble> {
        let num = Int(n ?? count)
        let xstart = Int(offset ?? 0)
        let xstr = Int(stride ?? 1)
        
        let rex = DataCon<CDouble>(capacity: UInt(num))
        for idx in 0 ..< num {
            let xdx = xstart + idx * xstr
            rex[num - 1 - idx] = data[xdx]
        }
        return rex
    }
    
    // MARK: copies/inits
    
    func deepcopy() -> DataCon<CDouble>
    {
        // func cblas_dcopy(_ __N: Int32, _ __X: UnsafePointer<Double>!, _ __incX: Int32, _ __Y: UnsafeMutablePointer<Double>!, _ __incY: Int32)
        let rex: DataCon<CDouble> = DataCon(repeating: CDouble.Zero, count: DataCon.Index(self.count))

        let one = Int32(1)
        let N = Int32(count)
        cblas_dcopy(N, data, one, rex.data, one)
        return rex
    }

    /// copy _n_ elements _from_
    func set(from: DataCon<CDouble>, n: UInt? = nil, xoffset: UInt? = nil, xstride: UInt? = nil, yoffset: UInt? = nil, ystride: UInt? = nil)
    {
        // _x_ is src, _y_ is dst
        let num = Int32(n ?? UInt(min(count, from.count)))
        let xptr = from.data + Int(xoffset ?? 0)
        let xstr = Int32(xstride ?? 1)
        let yptr = data + Int(yoffset ?? 0)
        let ystr = Int32(ystride ?? 1)
        cblas_dcopy(num, xptr, xstr, yptr, ystr)
    }

    /// return container filled with given *Double* value
    /// Params -
    /// val: Double
    /// count: UInt
    static func BLASConstant(_ val: CDouble, _ n: UInt) -> DataCon<Double>
    {
        let rex: DataCon<CDouble> = DataCon(capacity: n)
        catlas_dset(Int32(rex.count), val, rex.data, 1)
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


