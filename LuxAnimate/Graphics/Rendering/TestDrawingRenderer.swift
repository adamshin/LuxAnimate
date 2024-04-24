//
//  TestDrawingRenderer.swift
//

import Foundation
import Metal

struct TestDrawingRenderer {
    
    let renderTarget: RenderTarget
    
    private let viewportSize: Size
    private let drawingSize: Size
    
    private let drawingTexture: MTLTexture
    
    private let spriteRenderer = SpriteRenderer()
    
    init(
        renderTargetSize: PixelSize,
        viewportSize: Size,
        drawingSize: Size,
        drawingTexture: MTLTexture
    ) {
        self.viewportSize = viewportSize
        self.drawingSize = drawingSize
        self.drawingTexture = drawingTexture
        
        renderTarget = RenderTarget(size: renderTargetSize)
    }
    
    func draw() {
        let commandBuffer = MetalInterface.shared.commandQueue
            .makeCommandBuffer()!
        
        spriteRenderer.drawSprite(
            commandBuffer: commandBuffer,
            destination: renderTarget.texture,
            clearColor: Color(1, 1, 1, 1),
            viewportSize: viewportSize,
            texture: drawingTexture,
            size: drawingSize,
            position: .init(
                viewportSize.width / 2,
                viewportSize.height / 2))
        
        commandBuffer.commit()
    }
    
}
