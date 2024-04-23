//
//  SpriteRenderer.swift
//

import Foundation
import Metal

class SpriteRenderer {
    
    private let pipelineState: MTLRenderPipelineState
    
    init(pixelFormat: MTLPixelFormat) {
        let library = MetalInterface.shared.device
            .makeDefaultLibrary()!
        
        let vertexFunction = library.makeFunction(
            name: "spriteVertexShader")
        let fragmentFunction = library.makeFunction(
            name: "spriteFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.pixelFormat = pixelFormat
        
        pipelineState = try! MetalInterface.shared.device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func drawSprite(
        commandBuffer: any MTLCommandBuffer,
        destination: MTLTexture,
        clearColor: Color?,
        viewportSize: Size,
        texture: MTLTexture,
        size: Size,
        position: Vector,
        rotation: Scalar = 0,
        scale: Scalar = 1,
        alpha: Double = 1,
        blendMode: BlendMode = .normal
    ) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = destination
        attachment.storeAction = .store
        
        attachment.loadAction = clearColor != nil ?
            .clear : .load
        attachment.clearColor = clearColor?.mtlClearColor ??
            MTLClearColorMake(0, 0, 0, 1)
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(
                descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var t = Matrix3.identity
        t = Matrix3(translation: .init(-0.5, -0.5)) * t
        t = Matrix3(scale: .init(size.width, size.height)) * t
        t = Matrix3(scale: .init(scale, scale)) * t
        t = Matrix3(rotation: rotation) * t
        t = Matrix3(translation: position) * t
        
        let vertexPositions: [Vector] = [
            .init(0, 0), .init(1, 0),
            .init(0, 1), .init(1, 1)
        ]
        let vertices = vertexPositions.map { p in
            let tp = t * p
            return SpriteVertex(
                position: .init(
                    x: Float(tp.x),
                    y: Float(tp.y)),
                texCoord: .init(
                    x: Float(p.x),
                    y: Float(p.y)))
        }
        
        var vertexUniforms = SpriteVertexUniforms(
            viewportSize: .init(
                Float(viewportSize.width),
                Float(viewportSize.height)))
        
        var fragmentUniforms = SpriteFragmentUniforms(
            alpha: Float(alpha),
            blendMode: blendMode.shaderBlendMode)
        
        renderEncoder.setVertexBytes(
            vertices,
            length: MemoryLayout<SpriteVertex>.stride * vertices.count,
            index: Int(SpriteVertexBufferIndexVertices.rawValue))
        
        renderEncoder.setVertexBytes(
            &vertexUniforms,
            length: MemoryLayout<SpriteVertexUniforms>.stride,
            index: Int(SpriteVertexBufferIndexUniforms.rawValue))
        
        renderEncoder.setFragmentBytes(
            &fragmentUniforms,
            length: MemoryLayout<SpriteFragmentUniforms>.stride,
            index: Int(SpriteFragmentBufferIndexUniforms.rawValue))
        
        renderEncoder.setFragmentTexture(texture, index: 0)
        
        renderEncoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: vertices.count)
         
        renderEncoder.endEncoding()
    }
    
}
