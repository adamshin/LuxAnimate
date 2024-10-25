
import Foundation

public typealias Vector = Vector2

public struct Vector2: Sendable, Codable {
    var x, y: Scalar
}

public extension Vector2 {
    
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
