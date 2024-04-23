//
//  TestDrawingRenderer.swift
//

import Foundation
import Metal

struct TestDrawingRenderer {
    
    private let framebufferSize: PixelSize
    private let viewportSize: Size
    private let drawingSize: Size
    
    private let framebuffer: MTLTexture
    private let drawingTexture: MTLTexture
    
    private let spriteRenderer = SpriteRenderer(
        pixelFormat: .rgba8Unorm)
    
    init(
        framebufferSize: PixelSize,
        viewportSize: Size,
        drawingSize: Size,
        drawingTexture: MTLTexture
    ) {
        self.framebufferSize = framebufferSize
        self.viewportSize = viewportSize
        self.drawingSize = drawingSize
        self.drawingTexture = drawingTexture
        
        // Framebuffer
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = framebufferSize.width
        texDescriptor.height = framebufferSize.height
        texDescriptor.pixelFormat = .rgba8Unorm
        texDescriptor.storageMode = .private
        texDescriptor.usage = [.renderTarget, .shaderRead]
        
        framebuffer = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
    }
    
    func draw() {
        let commandBuffer = MetalInterface.shared.commandQueue
            .makeCommandBuffer()!
        
        spriteRenderer.drawSprite(
            commandBuffer: commandBuffer,
            destination: framebuffer,
            clearColor: Color(0, 0, 0, 1),
            viewportSize: viewportSize,
            texture: drawingTexture,
            size: drawingSize,
            position: .init(
                viewportSize.width / 2,
                viewportSize.height / 2))
        
        commandBuffer.commit()
    }
    
    func getFramebuffer() -> MTLTexture {
        framebuffer
    }
    
}
