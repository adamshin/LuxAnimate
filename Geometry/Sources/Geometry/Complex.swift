
import Foundation
import simd

public struct Complex: Sendable {
    
    private var storage: simd_double2
    
    private init(_ storage: simd_double2) {
        self.storage = storage
    }
    
}

// MARK: - Properties

public extension Complex {
    
    var real: Double {
        get { storage.x }
        set { storage.x = newValue }
    }
    var imaginary: Double {
        get { storage.y }
        set { storage.y = newValue }
    }
    
    internal var x: Double { storage.x }
    internal var y: Double { storage.y }
    
}

// MARK: - Operations

public extension Complex {
    
    static let zero = Complex(0, 0)
    static let one = Complex(1, 0)
    static let i = Complex(0, 1)
    
    init(real: Double, imaginary: Double) {
        self.storage = .init(real, imaginary)
    }
    
    init(_ real: Double, _ imaginary: Double) {
        self.storage = .init(real, imaginary)
    }
    
    init(length: Double, phase: Double) {
        self = Complex(cos(phase), sin(phase)) * length
    }
    
    var isZero: Bool {
        x == 0 && y == 0
    }
    
    var conjugate: Complex {
        Complex(x, -y)
    }
    
    func normalized() -> Complex {
        Complex(simd_normalize(storage))
    }
    
    func length() -> Double {
        simd_length(storage)
    }
    
    var phase: Double {
        guard !isZero else { return .nan }
        return atan2(y, x)
    }
    
    static prefix func - (c: Complex) -> Complex {
        Complex(-c.storage)
    }
    
    static func + (lhs: Complex, rhs: Complex) -> Complex {
        Complex(lhs.storage + rhs.storage)
    }
    
    static func - (lhs: Complex, rhs: Complex) -> Complex {
        Complex(lhs.storage - rhs.storage)
    }
    
    static func * (lhs: Complex, rhs: Complex) -> Complex {
        Complex(
            lhs.x*rhs.x - lhs.y*rhs.y,
            lhs.x*rhs.y + lhs.y*rhs.x)
    }
    
    static func * (lhs: Complex, rhs: Double) -> Complex {
        Complex(lhs.storage * rhs)
    }
    
    static func * (lhs: Double, rhs: Complex) -> Complex {
        Complex(lhs * rhs.storage)
    }
    
    static func / (lhs: Complex, rhs: Double) -> Complex {
        Complex(lhs.storage / rhs)
    }
    
    static func += (lhs: inout Complex, rhs: Complex) {
        lhs.storage += rhs.storage
    }
    
    static func -= (lhs: inout Complex, rhs: Complex) {
        lhs.storage -= rhs.storage
    }
    
    static func *= (lhs: inout Complex, rhs: Complex) {
        lhs = lhs * rhs
    }
    
    static func *= (lhs: inout Complex, rhs: Double) {
        lhs.storage *= rhs
    }
    
    static func /= (lhs: inout Complex, rhs: Double) {
        lhs.storage /= rhs
    }
    
}

// MARK: - Codable

extension Complex: Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Double.self)
        let y = try container.decode(Double.self)
        self.init(x, y)
    }
    
}
