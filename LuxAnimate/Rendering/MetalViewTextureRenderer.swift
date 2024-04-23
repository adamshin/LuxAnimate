//
//  MetalViewTextureRenderer.swift
//

import Foundation
import MetalKit

class MetalViewTextureRenderer {
    
    private let pipelineState: MTLRenderPipelineState
    
    init() {
        // Render pipeline
        let library = MetalInterface.shared.device.makeDefaultLibrary()!
        let vertexFuction = library.makeFunction(name: "spriteVertexShader")
        let fragmentFunction = library.makeFunction(name: "spriteFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFuction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.pixelFormat = .bgra8Unorm
        
        pipelineState = try! MetalInterface.shared.device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func draw(texture: MTLTexture, to layer: CAMetalLayer) {
        guard let drawable = layer.nextDrawable() else { return }
        
        let commandBuffer = MetalInterface.shared.commandQueue
            .makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = drawable.texture
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        let vertexPositions: [(Float, Float)] = [
            (0, 0), (1, 0),
            (0, 1), (1, 1)
        ]
        let vertices = vertexPositions.map {
            SpriteVertex(
                position: .init(x: $0.0, y: $0.1),
                texCoord: .init(x: $0.0, y: $0.1))
        }
        
        var vertexUniforms = SpriteVertexUniforms(
            viewportSize: .init(1, 1))
        
        var fragmentUniforms = SpriteFragmentUniforms(
            alpha: 1.0,
            blendMode: ShaderBlendModeNormal)
        
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
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}
