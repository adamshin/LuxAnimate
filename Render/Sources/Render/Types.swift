
import Foundation
import Geometry
import Color
import ShaderTypes

public enum BlendMode {
    case normal
    case erase
    case replace
}

public enum SampleMode {
    case nearest
    case linear
    case linearClampEdgeToBlack
}

public enum ColorMode {
    case none
    case multiply
    case stencil
    case brush
}


extension BlendMode {
    var shaderValue: ShaderBlendMode {
        switch self {
        case .normal: ShaderBlendModeNormal
        case .erase: ShaderBlendModeErase
        case .replace: ShaderBlendModeReplace
        }
    }
}

extension SampleMode {
    var shaderValue: ShaderSampleMode {
        switch self {
        case .nearest: ShaderSampleModeNearest
        case .linear: ShaderSampleModeLinear
        case .linearClampEdgeToBlack: ShaderSampleModeLinearClampEdgeToBlack
        }
    }
}

extension ColorMode {
    var shaderValue: ShaderColorMode {
        switch self {
        case .none: ShaderColorModeNone
        case .multiply: ShaderColorModeMultiply
        case .stencil: ShaderColorModeStencil
        case .brush: ShaderColorModeBrush
        }
    }
}

extension SpriteVertex {
    
    init(
        position: Vector,
        texCoord: Vector,
        color: Color,
        alpha: Double
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
