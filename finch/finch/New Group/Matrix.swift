//
//  Matrix.swift
//  finch
//
//  Created by Matthew Patterson on 6/23/18.
//  Copyright © 2018 octeps. All rights reserved.
//

import Foundation
import Accelerate

// assumption here is Double, dense, no structural constraint
struct Matrix : BLASMatrixProtocol {
    typealias Element = CDouble
    
    let memview: MatrixMemView
    let datacon: DataCon<Element>
    
    /// the BLAS stride of the underlying container: zero if not stridable
    /// return -
    /// nil if not vector-stride-able, else vector-stride
    /// but I do not yet know iff for vector-stride-able
    var stride: UInt? {
        get {
//            guard memview.row_stride == 1 else {
//                return nil
//            }
            return memview.row_stride
        }
    }
    
    var count: UInt {
        get {
            return memview.count
        }
    }
    
    var data_offset: UInt {
        get {
            return memview.dataoff
        }
    }
    
    var data_interleaved: Bool {
        get {
             return memview.count == datacon.count
        }
    }
    
    /// leading dimension
    var ld: UInt? {
        get {
            // TODO: is this what I want?
            guard count == datacon.count else {
                // the data is interleaved...make sure it is right when have use-case
                return nil
            }
            return nrows
        }
    }
    
    /*
     /// Computes the sum of the absolute values of elements in a vector (double-precision).
     func cblas_dasum(Int32, UnsafePointer<Double>!, Int32) -> Double
     
     /// Computes a constant times a vector plus a vector (double-precision).
     func cblas_daxpy(Int32, Double, UnsafePointer<Double>!, Int32, UnsafeMutablePointer<Double>!, Int32)

     /// Copies a vector to another vector (double-precision).
     func cblas_dcopy(Int32, UnsafePointer<Double>!, Int32, UnsafeMutablePointer<Double>!, Int32)
     
     /// Scales a general band matrix, then multiplies by a vector, then adds a vector (double precision).
     func cblas_dgbmv(CBLAS_ORDER, CBLAS_TRANSPOSE, Int32, Int32, Int32, Int32, Double, UnsafePointer<Double>!, Int32, UnsafePointer<Double>!, Int32, Double, UnsafeMutablePointer<Double>!, Int32)
     
     /// Multiplies two matrices (double-precision).
     func cblas_dgemm(CBLAS_ORDER, CBLAS_TRANSPOSE, CBLAS_TRANSPOSE, Int32, Int32, Int32, Double, UnsafePointer<Double>!, Int32, UnsafePointer<Double>!, Int32, Double, UnsafeMutablePointer<Double>!, Int32)
     
     /// Multiplies a matrix by a vector (double precision).
     func cblas_dgemv(CBLAS_ORDER, CBLAS_TRANSPOSE, Int32, Int32, Double, UnsafePointer<Double>!, Int32, UnsafePointer<Double>!, Int32, Double, UnsafeMutablePointer<Double>!, Int32)
     
     /// Multiplies vector X by the transform of vector Y, then adds matrix A (double precison).
     func cblas_dger(CBLAS_ORDER, Int32, Int32, Double, UnsafePointer<Double>!, Int32, UnsafePointer<Double>!, Int32, UnsafeMutablePointer<Double>!, Int32)
     
     /// Computes the L2 norm (Euclidian length) of a vector (double precision).
     func cblas_dnrm2(Int32, UnsafePointer<Double>!, Int32) -> Double
     
     */
    
    
    /// This function multiplies A * B and multiplies the resulting matrix by alpha.
    /// It then multiplies matrix C by beta.
    /// It stores the sum of these two products in matrix C.
    ///
    /// Thus, it calculates either
    ///
    /// C←αAB + βC
    ///
    /// or
    ///
    /// C←αBA + βC
    // Order - Specifies row-major (C) or column-major (Fortran) data ordering.
    // TransA - Specifies whether to transpose matrix A
    // TransB - Specifies whether to transpose matrix B
    // M - Number of rows in matrices A and C.
    // N - Number of columns in matrices B and C.
    // K - Number of columns in matrix A; number of rows in matrix B.
    // alpha - Scaling factor for the product of matrices A and B.
    // A - Matrix A.
    // lda - The size of the first dimention of matrix A; if you are passing a matrix A[m[n], /// the value should be m.
    // B - Matrix B.
    // ldb - The size of the first dimention of matrix B; if you are passing a matrix B[m[n], /// the value should be m.
    // beta - Scaling factor for matrix C.
    // C - Matrix C.
    // ldc - The size of the first dimention of matrix C; if you are passing a matrix C[m][n], /// the value should be m.
    static func dgemm(A: Matrix, B: Matrix, C: Matrix, alpha: CDouble, beta: CDouble) {
        let M = Int32(A.nrows)
        let N = Int32(B.ncols)
        let K = Int32(A.ncols)
        let a = A.data_const_ptr
        let lda = Int32(A.nrows)
        let b = B.data_const_ptr
        let ldb = Int32(B.nrows)
        let c = C.data_mtble_ptr
        let ldc = Int32(C.nrows)
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, M, N, K, 1.0, a, lda, b, ldb, 1.0, c, ldc)
    }
    
    static func *(_ x: Matrix, _ y: Matrix) -> Matrix? {
        guard x.ncols == y.nrows else {
            return nil
        }
        let rex = Matrix(x.nrows, y.ncols)
        dgemm(A: x, B: y, C: rex, alpha: 1.0, beta: 0.0)
        return rex
    }
    
    static func *(_ x: Matrix, _ a: CDouble) -> Matrix {
        let rex = Matrix(deepCopyFrom: x)

        if rex.data_interleaved {
            // TODO - this is not implemented
            return rex
        } else {
            // in the simple case, call faster scale
            /// func scale_inplace(_ alpha: Double, n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil)
            rex.datacon.scale_inplace(a, n: x.count, stride: 1, offset: x.data_offset)
        }
        return rex
    }
    

    
    /// a * x + b * y -> x
    func axpby_inplace(a: CDouble, b: CDouble, y: Matrix) throws {
        // TODO: here, and everywhere else, it is unsafe to use the same pointer more
        // than once in a BLAS call: test to see if this is happeneing (somewhere)
        // and use a safe alternative if it is -- log that it happened
        guard shape == y.shape else {
            throw Exceptions.ShapeMismatch
        }
        datacon.axpby_inplace(a, y.datacon, b, n: count, xstride: stride, xoffset: data_offset, ystride: y.stride, yoffset: y.data_offset)
    }
    
    /// a * x + b * y -> y
    func axpby(a: CDouble, b: CDouble, y: Matrix) throws {
        
        //let rex = Matrix(deepCopyFrom: self)
        do {
            try y.axpby_inplace(a: b, b: a, y: self)
        } catch Exceptions.ShapeMismatch {
            throw Exceptions.ShapeMismatch  // may be something else to do
        } catch _ {
            throw Exceptions.Unknown("confusing Exception")
        }
    }
    
    static func +(_ x: Matrix, _ y: Matrix) throws -> Matrix {
        guard x.shape == y.shape else {
            throw Exceptions.ShapeMismatch
        }
        let rex = Matrix(deepCopyFrom: x)
        do {
            try rex.axpby_inplace(a: 1.0, b: 1.0, y: y)
        } catch Exceptions.ShapeMismatch {
            throw Exceptions.ShapeMismatch  // may be something else to do
        } catch _ {
            throw Exceptions.Unknown("confusing Exception")
        }
        return rex
    }
    
    static func +=(_ x: Matrix, _ y: Matrix) throws {
        guard x.shape == y.shape else {
            throw Exceptions.ShapeMismatch
        }
        do {
            try x.axpby_inplace(a: 1.0, b: 1.0, y: y)
        } catch Exceptions.ShapeMismatch {
            throw Exceptions.ShapeMismatch  // may be something else to do
        } catch _ {
            throw Exceptions.Unknown("confusing Exception")
        }
    }
    
    static func -(_ x: Matrix, _ y: Matrix) throws -> Matrix {
        guard x.shape == y.shape else {
            throw Exceptions.ShapeMismatch
        }
        let rex = Matrix(deepCopyFrom: y)
        do {
            try rex.axpby_inplace(a: -1.0, b: 1.0, y: y)
        } catch Exceptions.ShapeMismatch {
            throw Exceptions.ShapeMismatch  // may be something else to do
        } catch _ {
            throw Exceptions.Unknown("confusing Exception")
        }
        return rex
    }
    
    static func -=(_ x: Matrix, _ y: Matrix) throws {
        guard x.shape == y.shape else {
            throw Exceptions.ShapeMismatch
        }
        do {
            try x.axpby_inplace(a: 1.0, b: -1.0, y: y)
        } catch Exceptions.ShapeMismatch {
            throw Exceptions.ShapeMismatch  // may be something else to do
        } catch _ {
            throw Exceptions.Unknown("confusing Exception")
        }
    }

    // MARK: negates
    static prefix func - (_ x: Matrix) -> Matrix {
        return x.negate()
    }
    
    func negate_inplace(n: UInt? = nil, stride: UInt? = nil, offset: UInt? = nil)
    {
        datacon.negate_inplace(n: count, stride: stride, offset: data_offset)
    }
    
    func negate() -> Matrix
    {
        let rex = Matrix(deepCopyFrom: self)
        rex.datacon.negate_inplace(n: rex.count, stride: rex.stride, offset: rex.data_offset)
        return rex
    }
    
    func scale(_ a: CDouble) -> Matrix {
        let rex = Matrix(deepCopyFrom: self)
        rex.datacon.scale_inplace(a, n: count, stride: stride, offset: data_offset)
        return rex
    }
    
    func scale_inplace(_ a: CDouble) {
        datacon.scale_inplace(a, n: count, stride: stride, offset: data_offset)
    }

    /// map the function, returning new
    func map(_ f: (Element) -> Element) -> Matrix {
        let rex = Matrix(deepCopyFrom: self)
        rex.map_inplace(f)
        return rex
    }

    /// get/set the _idx_-th row as a *Vector*
    /// get returns *nil* when data unavailable
    /// set is just unsafe
    subscript(idx: UInt) -> Vector {
        get {
            return Vector(datacon, memview.row(idx))
        }
        set (x) {
            let v = x
            let fromOffset = v.memview.dataoff
            let fromStride = v.isRowVector ? v.memview.datastd.col_stride : v.memview.datastd.row_stride
            let toOffset = memview.dataoff
            let toStride = memview.datastd.col_stride
            self.datacon.set(from: v.datacon, n: fromOffset, xoffset: fromStride, xstride: toOffset, yoffset: toStride)
            // TODO - add *throws* ??
        }
    }
    
    /// get a row
    func row(_ idx: UInt, safe: Bool = true, deepcopy: Bool = false) -> Vector? {
        guard !safe || idx < nrows else {
            return nil
        }
        return Vector(deepcopy ? datacon.deepcopy(): datacon, memview.row(idx))
    }
    
    /// get a col
    func col(_ idx: UInt, safe: Bool = true, deepcopy: Bool = false) -> Vector? {
        guard !safe || idx < nrows else {
            return nil
        }
        return Vector(deepcopy ? datacon.deepcopy(): datacon, memview.col(idx))
    }

    // MARK: inits
    
    /// deepcopy ctor
    init(deepCopyFrom x: Matrix) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon.deepcopy()
    }

    /// normal swift assignment gives shallow...or does it
    init(_ x: Matrix) {
        memview = MatrixMemView(x.memview)
        datacon = x.datacon
    }
    init(_ data_con: DataCon<Element>, _ mem_view: MatrixMemView) {
        datacon = data_con
        memview = mem_view
    }

    /// simple ctors when only shape is perscribed
    init(_ n: UInt) {
        memview = MatrixMemView(n)
        datacon = DataCon<Element>(capacity: n * n)
    }
    init(_ nrows: UInt, _ ncols: UInt) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<Element>(capacity: nrows * ncols)
    }
    
    /// ctors with shape and indexed function
    init(_ n: UInt, _ f: (UInt, UInt) -> Element) {
        memview = MatrixMemView(n)
        datacon = DataCon<Element>(capacity: n * n)
        map_inplace(f)
    }
    init(_ nrows: UInt, _ ncols: UInt, _ f: (UInt, UInt) -> Element) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<Element>(capacity: nrows * ncols)
        map_inplace(f)
    }
    
    /// ctors with shape and fixed value
    init(_ n: UInt, doubleValue x: Element) {
        memview = MatrixMemView(n)
        datacon = DataCon<Element>(repeating: x, count: Int(n * n))
    }
    init(_ nrows: UInt, _ ncols: UInt, doubleValue x: Element) {
        memview = MatrixMemView([nrows, ncols])
        datacon = DataCon<Element>(repeating: x, count: Int(nrows * ncols))
    }
    
    init?(_ data: [[Element]]) {
        guard data.allSatisfy({(x: [Element]) in
            return x.count == data[0].count
        }) else {
            return nil
        }
        memview = MatrixMemView([UInt(data.count), UInt(data[0].count)])
        datacon = DataCon<Element>(capacity: memview.shape.nrows * memview.shape.ncols)
        // TODO: figure out when casts/coersions happen & do they burn time
        for idx in 0 ..< memview.shape.nrows {
            for jdx in 0 ..< memview.shape.ncols {
                let ddx = Int(memview.data_index(idx, jdx))
                datacon[ddx] = data[Int(idx)][Int(jdx)]
            }
        }
    }
    
    // MARK: modify
    func transpose() -> Matrix {
        return Matrix(datacon, memview.transpose())
    }
    // TODO: ...
    func transpose_inplace() -> Matrix {
        return Matrix(datacon, memview.transpose())
    }

    // MARK: static ctors
    
    /// identity *Matrix* of size _n_
    static func Eye(_ n: UInt) -> Matrix {
        let rex = Matrix.Zeros(n)
        for idx in 0 ..< n {
            rex.datacon[DataCon<Element>.Index(idx * n)] = 1.0
        }
        return rex
    }

    /// square *Matrix* of size _n_ of all zeros
    static func Zeros(_ n: UInt) -> Matrix {
        let dc = DataCon<Element>.BLASConstant(0.0, n * n)
        let rex = Matrix(dc, MatrixMemView(n))
        return rex
    }
    
    /// square *Matrix* of size _m x n_ of all zeros
    static func Zeros(_ m: UInt, _ n: UInt) -> Matrix {
        let dc = DataCon<Element>.BLASConstant(0.0, m * n)
        let rex = Matrix(dc, MatrixMemView([m, n]))
        return rex
    }
}
