//
//  TestRenderer.swift
//

import Foundation
import Metal

struct TestRenderer {
    
    private let framebuffer: MTLTexture
    private let pipelineState: MTLRenderPipelineState
    
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
        let vertexFuction = library.makeFunction(name: "textureVertexShader")
        let fragmentFunction = library.makeFunction(name: "textureFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFuction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.pixelFormat = .rgba8Unorm
        
        pipelineState = try! MetalInterface.shared.device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func draw() {
        let commandBuffer = MetalInterface.shared.commandQueue
            .makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = framebuffer
        attachment.storeAction = .store
        attachment.loadAction = .clear
        attachment.clearColor = MTLClearColorMake(1, 0, 0, 1)
        
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.endEncoding()
        commandBuffer.commit()
    }
    
    func getFramebuffer() -> MTLTexture { framebuffer }
    
}
