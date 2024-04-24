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

enum SampleMode {
    case nearest
    case linear
}

enum ColorMode {
    case none
    case multiply
    case brush
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
    var shaderValue: ShaderBlendMode {
        switch self {
        case .normal: ShaderBlendModeNormal
        }
    }
}

extension SampleMode {
    var shaderValue: ShaderSampleMode {
        switch self {
        case .nearest: ShaderSampleModeNearest
        case .linear: ShaderSampleModeLinear
        }
    }
}

extension ColorMode {
    var shaderValue: ShaderColorMode {
        switch self {
        case .none: ShaderColorModeNone
        case .multiply: ShaderColorModeMultiply
        case .brush: ShaderColorModeBrush
        }
    }
}
