//
//  DrawingEditorFrameRenderer.swift
//

import Foundation
import Metal

class DrawingEditorFrameRenderer {
    
    private let backgroundColor: Color
    
    let texture: MTLTexture
    
    private let spriteRenderer = SpriteRenderer()
    
    init(
        drawingSize: PixelSize,
        backgroundColor: Color
    ) {
        self.backgroundColor = backgroundColor
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = drawingSize.width
        texDesc.height = drawingSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .private
        texDesc.usage = [.renderTarget, .shaderRead]
        
        texture = MetalInterface.shared.device
            .makeTexture(descriptor: texDesc)!
    }
    
    func draw(drawingTexture: MTLTexture) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: texture,
            color: backgroundColor)
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: texture,
            viewportSize: Size(1, 1),
            texture: drawingTexture,
            sprites: [
                SpriteRenderer.Sprite(
                    size: Size(1, 1),
                    position: Vector(0.5, 0.5))
            ])
        
        commandBuffer.commit()
    }
    
}
