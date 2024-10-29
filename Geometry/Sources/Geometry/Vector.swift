
import Foundation

public typealias Vector = Vector2

public struct Vector2: Sendable, Codable {
    
    public var x, y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
}

public extension Vector2 {
    
    static let zero = Vector2(0, 0)
    
    init(_ x: Double, _ y: Double) {
        self.init(x: x, y: y)
    }
    
    var inverse: Vector2 {
        -self
    }
    
    var perpendicularClockwise: Vector2 {
        Vector2(y, -x)
    }
    
    func lengthSquared() -> Double {
        x * x + y * y
    }
    
    func length() -> Double {
        sqrt(lengthSquared())
    }
    
    func dot(_ v: Vector2) -> Double {
        x * v.x + y * v.y
    }
    
    func normalized() -> Vector2 {
        self / length()
    }
    
    func rotated(by a: Double) -> Vector2 {
        let cs = cos(a)
        let sn = sin(a)
        return Vector2(x * cs - y * sn, x * sn + y * cs)
    }
    
    func angle(to v: Vector2) -> Double {
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
    
    static func * (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(lhs.x * rhs, lhs.y * rhs)
    }
    
    static func * (lhs: Double, rhs: Vector2) -> Vector2 {
        Vector2(lhs * rhs.x, lhs * rhs.y)
    }
    
    static func / (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(lhs.x / rhs, lhs.y / rhs)
    }
    
    static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }
    
    static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }
    
    static func *= (lhs: inout Vector2, rhs: Double) {
        lhs = lhs * rhs
    }
    
    static func /= (lhs: inout Vector2, rhs: Double) {
        lhs = lhs / rhs
    }
    
}
