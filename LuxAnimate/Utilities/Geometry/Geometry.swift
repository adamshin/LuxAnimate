//
//  Geometry.swift
//

import Foundation

// MARK: - Scalar

typealias Scalar = Double

extension Scalar {
    static let halfPi = pi / 2
    static let quarterPi = pi / 4
    static let twoPi = pi * 2
    static let degreesPerRadian = 180 / pi
    static let radiansPerDegree = pi / 180
}

// MARK: - Vector

typealias Vector = Vector2

struct Vector2 {
    var x, y: Scalar
}

extension Vector2 {
    
    static let zero = Vector2(0, 0)
    
    init(_ x: Scalar, _ y: Scalar) {
        self.init(x: x, y: y)
    }
    
    var inverse: Vector2 {
        -self
    }
    
    var perpendicularClockwise: Vector2 {
        Vector2(y, -x)
    }
    
    func lengthSquared() -> Scalar {
        x * x + y * y
    }
    
    func length() -> Scalar {
        sqrt(lengthSquared())
    }
    
    func dot(_ v: Vector2) -> Scalar {
        x * v.x + y * v.y
    }
    
    func normalized() -> Vector2 {
        self / length()
    }
    
    func rotated(by a: Scalar) -> Vector2 {
        let cs = cos(a)
        let sn = sin(a)
        return Vector2(x * cs - y * sn, x * sn + y * cs)
    }
    
    func angle(to v: Vector2) -> Scalar {
        atan2(x * v.y - y * v.x, x * v.x + y * v.y)
    }
    
    static prefix func - (v: Vector2) -> Vector2 {
        Vector2(-v.x, -v.y)
    }
    
    static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    static func * (lhs: Vector2, rhs: Scalar) -> Vector2 {
        Vector2(lhs.x * rhs, lhs.y * rhs)
    }
    
    static func * (lhs: Scalar, rhs: Vector2) -> Vector2 {
        Vector2(lhs * rhs.x, lhs * rhs.y)
    }
    
    static func / (lhs: Vector2, rhs: Scalar) -> Vector2 {
        Vector2(lhs.x / rhs, lhs.y / rhs)
    }
    
    static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }
    
    static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }
    
    static func *= (lhs: inout Vector2, rhs: Scalar) {
        lhs = lhs * rhs
    }
    
    static func /= (lhs: inout Vector2, rhs: Scalar) {
        lhs = lhs / rhs
    }
    
}

// MARK: - Matrix

struct Matrix3 {
    var m11, m12, m13: Scalar
    var m21, m22, m23: Scalar
    var m31, m32, m33: Scalar
}

extension Matrix3 {
    
    static let identity = Matrix3(
        1, 0, 0,
        0, 1, 0,
        0, 0, 1)
    
    init(
        _ m11: Scalar, _ m12: Scalar, _ m13: Scalar,
        _ m21: Scalar, _ m22: Scalar, _ m23: Scalar,
        _ m31: Scalar, _ m32: Scalar, _ m33: Scalar
    ) {
        self.m11 = m11; self.m12 = m12; self.m13 = m13
        self.m21 = m21; self.m22 = m22; self.m23 = m23
        self.m31 = m31; self.m32 = m32; self.m33 = m33
    }
    
    init(translation t: Vector2) {
        self.init(
            1, 0, t.x,
            0, 1, t.y,
            0, 0, 1)
    }
    
    init(rotation a: Scalar) {
        let cs = cos(a)
        let sn = sin(a)
        self.init(
            cs, -sn, 0,
            sn, cs, 0,
            0, 0, 1)
    }
    
    init(scale s: Vector2) {
        self.init(
            s.x, 0, 0,
            0, s.y, 0,
            0, 0, 1)
    }
    
    init(shearHorizontal a: Scalar) {
        self.init(
            1, tan(a), 0,
            0, 1, 0,
            0, 0, 1)
    }
    
    func adjugate() -> Matrix3 {
        Matrix3(
            m22 * m33 - m23 * m32,
            m13 * m32 - m12 * m33,
            m12 * m23 - m13 * m22,
            m23 * m31 - m21 * m33,
            m11 * m33 - m13 * m31,
            m13 * m21 - m11 * m23,
            m21 * m32 - m22 * m31,
            m12 * m31 - m11 * m32,
            m11 * m22 - m12 * m21
        )
    }

    func determinant() -> Scalar {
        (m11 * m22 * m33 + m12 * m23 * m31 + m13 * m21 * m32) -
        (m13 * m22 * m31 + m11 * m23 * m32 + m12 * m21 * m33)
    }

    func transpose() -> Matrix3 {
        Matrix3(
            m11, m21, m31,
            m12, m22, m32,
            m13, m23, m33)
    }

    func inverse() -> Matrix3 {
        adjugate() * (1 / determinant())
    }
    
    static func * (lhs: Matrix3, rhs: Scalar) -> Matrix3 {
        Matrix3(
            lhs.m11 * rhs, lhs.m12 * rhs, lhs.m13 * rhs,
            lhs.m21 * rhs, lhs.m22 * rhs, lhs.m23 * rhs,
            lhs.m31 * rhs, lhs.m32 * rhs, lhs.m33 * rhs)
    }
    
    static func * (lhs: Matrix3, rhs: Matrix3) -> Matrix3 {
        Matrix3(
            lhs.m11 * rhs.m11 + lhs.m12 * rhs.m21 + lhs.m13 * rhs.m31,
            lhs.m11 * rhs.m12 + lhs.m12 * rhs.m22 + lhs.m13 * rhs.m32,
            lhs.m11 * rhs.m13 + lhs.m12 * rhs.m23 + lhs.m13 * rhs.m33,
            lhs.m21 * rhs.m11 + lhs.m22 * rhs.m21 + lhs.m23 * rhs.m31,
            lhs.m21 * rhs.m12 + lhs.m22 * rhs.m22 + lhs.m23 * rhs.m32,
            lhs.m21 * rhs.m13 + lhs.m22 * rhs.m23 + lhs.m23 * rhs.m33,
            lhs.m31 * rhs.m11 + lhs.m32 * rhs.m21 + lhs.m33 * rhs.m31,
            lhs.m31 * rhs.m12 + lhs.m32 * rhs.m22 + lhs.m33 * rhs.m32,
            lhs.m31 * rhs.m13 + lhs.m32 * rhs.m23 + lhs.m33 * rhs.m33)
    }
    
    static func * (lhs: Matrix3, rhs: Vector2) -> Vector2 {
        return Vector2(
            lhs.m11 * rhs.x + lhs.m12 * rhs.y + lhs.m13,
            lhs.m21 * rhs.x + lhs.m22 * rhs.y + lhs.m23
        )
    }
    
}
