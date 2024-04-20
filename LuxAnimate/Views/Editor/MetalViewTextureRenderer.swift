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
        let vertexFuction = library.makeFunction(name: "textureVertexShader")
        let fragmentFunction = library.makeFunction(name: "textureFragmentShader")
        
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
            (0, 0), (0, 1),
            (1, 0), (1, 1)
        ]
        let vertices = vertexPositions.map {
            TextureVertex(
                position: .init(x: $0.0, y: $0.1),
                texCoord: .init(x: $0.0, y: $0.1))
        }
        
        let vertexBuffer = MetalInterface.shared.device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<TextureVertex>.stride)
        
        var frameData = FrameData(viewportSize: .init(1, 1))
        
        let frameDataBuffer = MetalInterface.shared.device.makeBuffer(
            bytes: &frameData,
            length: MemoryLayout<FrameData>.size,
            options: [])
        
        renderEncoder.setVertexBuffer(
            vertexBuffer,
            offset: 0,
            index: Int(VertexBufferIndexVertices.rawValue))
        
        renderEncoder.setVertexBuffer(
            frameDataBuffer,
            offset: 0,
            index: Int(VertexBufferIndexFrameData.rawValue))
        
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
