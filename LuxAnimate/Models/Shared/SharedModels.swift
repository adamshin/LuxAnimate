//
//  SharedModels.swift
//

import Foundation
import Metal

struct PixelSize {
    var width, height: Int
}

struct Color {
    var r, g, b, a: UInt8
}

enum BlendMode {
    case normal
}

// MARK: - Extensions

extension Color {
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
        self.init(r: r, g: g, b: b, a: a)
    }
    
    var mtlClearColor: MTLClearColor {
        MTLClearColorMake(Double(r), Double(g), Double(b), Double(a))
    }
    
}

extension BlendMode {
    
    var shaderBlendMode: ShaderBlendMode {
        switch self {
        case .normal: ShaderBlendModeNormal
        }
    }
    
}
