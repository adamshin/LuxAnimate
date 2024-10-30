
import Foundation
import simd

public typealias Vector = Vector2

public struct Vector2: Sendable, Codable {
    
    private var storage: simd_double2
    
    public var x: Double {
        get { storage.x }
        set { storage.x = newValue }
    }
    
    public var y: Double {
        get { storage.y }
        set { storage.y = newValue }
    }
    
    private init(_ storage: simd_double2) {
        self.storage = storage
    }
    
}

public extension Vector2 {
    
    static let zero = Vector2(0, 0)
    
    init(x: Double, y: Double) {
        self.storage = .init(x, y)
    }
    
    init(_ x: Double, _ y: Double) {
        self.storage = .init(x, y)
    }
    
    var inverse: Vector2 { -self }
    
    var perpendicularClockwise: Vector2 {
        Vector2(y, -x)
    }
    
    func lengthSquared() -> Double {
        simd_length_squared(storage)
    }
    
    func length() -> Double {
        simd_length(storage)
    }
    
    func dot(_ v: Vector2) -> Double {
        simd_dot(storage, v.storage)
    }
    
    func normalized() -> Vector2 {
        Vector2(simd_normalize(storage))
    }
    
    func rotated(by a: Double) -> Vector2 {
        return Matrix3(rotation: a) * self
    }
    
    func angle(to v: Vector2) -> Double {
        let cross = x * v.y - y * v.x
        let dot = dot(v)
        return atan2(cross, dot)
    }
    
    static prefix func - (v: Vector2) -> Vector2 {
        Vector2(-v.storage)
    }
    
    static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.storage + rhs.storage)
    }
    
    static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.storage - rhs.storage)
    }
    
    static func * (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(lhs.storage * rhs)
    }
    
    static func * (lhs: Double, rhs: Vector2) -> Vector2 {
        Vector2(lhs * rhs.storage)
    }
    
    static func / (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(lhs.storage / rhs)
    }
    
    static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs.storage += rhs.storage
    }
    
    static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs.storage -= rhs.storage
    }
    
    static func *= (lhs: inout Vector2, rhs: Double) {
        lhs.storage *= rhs
    }
    
    static func /= (lhs: inout Vector2, rhs: Double) {
        lhs.storage /= rhs
    }
    
}
