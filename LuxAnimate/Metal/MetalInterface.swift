//
//  MetalInterface.swift
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
                Float(color.r),
                Float(color.g),
                Float(color.b),
                Float(color.a)),
            alpha: Float(alpha))
    }
    
}
