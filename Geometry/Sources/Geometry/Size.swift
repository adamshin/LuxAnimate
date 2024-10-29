
import Foundation

public typealias Size = Size2

public struct Size2: Sendable, Codable {
    
    public var width, height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
}

public extension Size2 {
    
    static let zero = Size2(0, 0)
    
    init(_ width: Double, _ height: Double) {
        self.init(width: width, height: height)
    }
    
}
