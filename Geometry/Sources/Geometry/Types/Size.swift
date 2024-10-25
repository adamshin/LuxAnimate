
import Foundation

public typealias Size = Size2

public struct Size2: Sendable, Codable {
    var width, height: Scalar
}

public extension Size2 {
    
    static let zero = Size2(0, 0)
    
    init(_ width: Scalar, _ height: Scalar) {
        self.init(width: width, height: height)
    }
    
}
