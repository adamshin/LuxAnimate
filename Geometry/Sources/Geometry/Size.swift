
import Foundation

public typealias Size = Size2

public struct Size2: Sendable {
    
    public var width, height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    public init(_ width: Double, _ height: Double) {
        self.init(width: width, height: height)
    }
    
}

// MARK: - Operations

public extension Size2 {
    
    static let zero = Size2(0, 0)
    
}

// MARK: - Codable

extension Size2: Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(width)
        try container.encode(height)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let width = try container.decode(Double.self)
        let height = try container.decode(Double.self)
        self.init(width, height)
    }
    
}
