
import Foundation
import simd

public struct Matrix3: Sendable, Codable {
    
    private var storage: simd_double3x3
    
    public var m11: Double {
        get { storage.columns.0.x }
        set { storage.columns.0.x = newValue }
    }
    public var m12: Double {
        get { storage.columns.1.x }
        set { storage.columns.1.x = newValue }
    }
    public var m13: Double {
        get { storage.columns.2.x }
        set { storage.columns.2.x = newValue }
    }
    public var m21: Double {
        get { storage.columns.0.y }
        set { storage.columns.0.y = newValue }
    }
    public var m22: Double {
        get { storage.columns.1.y }
        set { storage.columns.1.y = newValue }
    }
    public var m23: Double {
        get { storage.columns.2.y }
        set { storage.columns.2.y = newValue }
    }
    public var m31: Double {
        get { storage.columns.0.z }
        set { storage.columns.0.z = newValue }
    }
    public var m32: Double {
        get { storage.columns.1.z }
        set { storage.columns.1.z = newValue }
    }
    public var m33: Double {
        get { storage.columns.2.z }
        set { storage.columns.2.z = newValue }
    }
    
    private init(_ storage: simd_double3x3) {
        self.storage = storage
    }
    
}

public extension Matrix3 {
    
    static let identity = Matrix3(matrix_identity_double3x3)
    
    init(
        _ m11: Double, _ m12: Double, _ m13: Double,
        _ m21: Double, _ m22: Double, _ m23: Double,
        _ m31: Double, _ m32: Double, _ m33: Double
    ) {
        self.storage = simd_double3x3(columns: (
            SIMD3(m11, m21, m31),
            SIMD3(m12, m22, m32),
            SIMD3(m13, m23, m33)
        ))
    }
    
    init(translation t: Vector2) {
        self.init(
            1, 0, t.x,
            0, 1, t.y,
            0, 0, 1)
    }
    
    init(rotation a: Double) {
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
    
    init(shearHorizontal a: Double) {
        self.init(
            1, tan(a), 0,
            0, 1, 0,
            0, 0, 1)
    }
    
    func determinant() -> Double {
        storage.determinant
    }
    
    func transpose() -> Matrix3 {
        Matrix3(storage.transpose)
    }
    
    func inverse() -> Matrix3 {
        Matrix3(storage.inverse)
    }
    
    static func * (lhs: Matrix3, rhs: Double) -> Matrix3 {
        Matrix3(lhs.storage * rhs)
    }
    
    static func * (lhs: Matrix3, rhs: Matrix3) -> Matrix3 {
        Matrix3(lhs.storage * rhs.storage)
    }
    
    static func * (lhs: Matrix3, rhs: Vector2) -> Vector2 {
        let v = SIMD3(rhs.x, rhs.y, 1)
        let result = lhs.storage * v
        return Vector2(result.x, result.y)
    }
    
}

// MARK: - Codable

extension simd_double3x3: Codable {
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let c0 = try container.decode(SIMD3<Double>.self)
        let c1 = try container.decode(SIMD3<Double>.self)
        let c2 = try container.decode(SIMD3<Double>.self)
        self.init(columns: (c0, c1, c2))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(columns.0)
        try container.encode(columns.1)
        try container.encode(columns.2)
    }
    
}
