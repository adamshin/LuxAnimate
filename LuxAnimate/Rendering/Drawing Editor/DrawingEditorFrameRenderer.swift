//
//  DrawingEditorFrameRenderer.swift
//

import Foundation
import Metal

class DrawingEditorFrameRenderer {
    
    private let backgroundColor: Color
    
    let renderTarget: RenderTarget
    private var drawingTexture: MTLTexture?
    
    private let spriteRenderer = SpriteRenderer()
    
    init(
        drawingSize: PixelSize,
        backgroundColor: Color
    ) {
        self.backgroundColor = backgroundColor
        renderTarget = RenderTarget(size: drawingSize)
    }
    
    func setDrawingTexture(_ drawingTexture: MTLTexture) {
        self.drawingTexture = drawingTexture
    }
    
    func draw(
        activeDrawingTexture: MTLTexture?
    ) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: renderTarget.texture,
            color: backgroundColor)
        
        if let currentDrawingTexture = 
            activeDrawingTexture ?? drawingTexture
        {
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget.texture,
                viewportSize: Size(1, 1),
                texture: currentDrawingTexture,
                sprites: [
                    SpriteRenderer.Sprite(
                        size: Size(1, 1),
                        position: Vector(0.5, 0.5))
                ])
        }
        
        commandBuffer.commit()
    }
    
}
