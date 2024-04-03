//
//  Vector.swift
//

import Foundation

typealias Vector = Vector2

struct Vector2 {
    var x: Scalar
    var y: Scalar
}

extension Vector2 {
    
    static let zero = Vector2(0, 0)
    
    init(_ x: Scalar, _ y: Scalar) {
        self.init(x: x, y: y)
    }
    
    func lengthSquared() -> Scalar {
        x * x + y * y
    }

    func length() -> Scalar {
        sqrt(lengthSquared())
    }

    var inverse: Vector2 {
        -self
    }

    func dot(_ v: Vector2) -> Scalar {
        return x * v.x + y * v.y
    }

    func cross(_ v: Vector2) -> Scalar {
        return x * v.y - y * v.x
    }

    func normalized() -> Vector2 {
        self / length()
    }

    func rotated(by angle: Scalar) -> Vector2 {
        let cs = cos(angle)
        let sn = sin(angle)
        return Vector2(x * cs - y * sn, x * sn + y * cs)
    }

    func rotated(by angle: Scalar, around pivot: Vector2) -> Vector2 {
        (self - pivot).rotated(by: angle) + pivot
    }

    func angle(with v: Vector2) -> Scalar {
        let t1 = normalized()
        let t2 = v.normalized()
        let cross = t1.cross(t2)
        let dot = max(-1, min(1, t1.dot(t2)))
        
        return atan2(cross, dot)
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
