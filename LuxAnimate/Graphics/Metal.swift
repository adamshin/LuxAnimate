//
//  Metal.swift
//

import Metal

// MARK: - MetalInterface

struct MetalInterface {
    
    static let shared = MetalInterface()
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
    }
    
}

// MARK: - Shader Types

enum BlendMode {
    case normal
    case replace
}

enum SampleMode {
    case nearest
    case linear
    case linearClampEdgeToZero
}

enum ColorMode {
    case none
    case multiply
    case brush
}


extension BlendMode {
    var shaderValue: ShaderBlendMode {
        switch self {
        case .normal: ShaderBlendModeNormal
        case .replace: ShaderBlendModeReplace
        }
    }
}

extension SampleMode {
    var shaderValue: ShaderSampleMode {
        switch self {
        case .nearest: ShaderSampleModeNearest
        case .linear: ShaderSampleModeLinear
        case .linearClampEdgeToZero: ShaderSampleModeLinearClampEdgeToZero
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

extension SpriteVertex {
    
    init(
        position: Vector,
        texCoord: Vector,
        color: Color,
        alpha: Scalar
    ) {
        self.init(
            position: .init(
                x: Float(position.x),
                y: Float(position.y)),
            texCoord: .init(
                x: Float(texCoord.x),
                y: Float(texCoord.y)),
            color: .init(
                Float(color.r) / 255,
                Float(color.g) / 255,
                Float(color.b) / 255,
                Float(color.a) / 255),
            alpha: Float(alpha))
    }
    
}
