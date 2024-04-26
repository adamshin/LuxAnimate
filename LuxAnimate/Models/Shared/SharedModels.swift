//
//  SharedModels.swift
//

import Foundation
import Metal

struct PixelSize: Codable {
    var width, height: Int
}

struct Color: Codable {
    var r, g, b, a: UInt8
}

// MARK: - Extensions

extension Color {
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
        self.init(r: r, g: g, b: b, a: a)
    }
    
    var mtlClearColor: MTLClearColor {
        MTLClearColorMake(Double(r), Double(g), Double(b), Double(a))
    }
    
    static let black = Color(0, 0, 0, 1)
    static let white = Color(1, 1, 1, 1)
    static let clear = Color(0, 0, 0, 0)
    
    static let red = Color(1, 0, 0, 1)
    static let green = Color(0, 1, 0, 1)
    static let blue = Color(0, 0, 1, 1)
    
}
