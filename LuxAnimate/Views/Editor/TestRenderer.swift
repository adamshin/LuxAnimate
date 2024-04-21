//
//  TestRenderer.swift
//

import Foundation
import UIKit
import Metal
import MetalKit

struct TestRenderer {
    
    private let framebuffer: MTLTexture
    private let pipelineState: MTLRenderPipelineState
    
    private let testImage: MTLTexture
    
    init(canvasWidth: Int, canvasHeight: Int) {
        // Framebuffer
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = canvasWidth
        texDescriptor.height = canvasHeight
        texDescriptor.pixelFormat = .rgba8Unorm
        texDescriptor.storageMode = .private
        texDescriptor.usage = [.renderTarget, .shaderRead]
        
        framebuffer = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
        
        // Render pipeline
        let library = MetalInterface.shared.device.makeDefaultLibrary()!
        let vertexFuction = library.makeFunction(name: "spriteVertexShader")
        let fragmentFunction = library.makeFunction(name: "spriteFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFuction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.pixelFormat = .rgba8Unorm
        
        pipelineState = try! MetalInterface.shared.device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        // Test image
        let url = Bundle.main.url(forResource: "testCanvas.jxl", withExtension: nil)!
        let data = try! Data(contentsOf: url)
        let output = try! JXLDecoder.decode(data: data)
        
        let texDescriptor2 = MTLTextureDescriptor()
        texDescriptor2.width = output.width
        texDescriptor2.height = output.height
        texDescriptor2.pixelFormat = .rgba8Unorm
        texDescriptor2.usage = [.shaderRead]
        
        testImage = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor2)!
        
        let bytesPerPixel = 4
        let bytesPerRow = output.width * bytesPerPixel
        
        output.data.withUnsafeBytes {
            let region = MTLRegionMake2D(
                0, 0,
                output.width,
                output.height)
            
            testImage.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: $0.baseAddress!,
                bytesPerRow: bytesPerRow)
        }
    }
    
    func draw() {
        let commandBuffer = MetalInterface.shared.commandQueue
            .makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = framebuffer
        attachment.storeAction = .store
        attachment.loadAction = .clear
        attachment.clearColor = MTLClearColorMake(1, 1, 1, 1)
        
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
        
        renderEncoder.setFragmentTexture(testImage, index: 0)
        
        renderEncoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: vertices.count)
         
        renderEncoder.endEncoding()
        
        commandBuffer.commit()
    }
    
    func getFramebuffer() -> MTLTexture { framebuffer }
    
}
