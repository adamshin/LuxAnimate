//
//  BrushEngineStampRenderer.swift
//

import Metal

struct BrushEngineStampRenderer {
    
    private let spriteRenderer = SpriteRenderer()
    
    func drawStamps(
        target: MTLTexture,
        viewportSize: Size,
        stamps: [BrushStrokeEngine.Stamp],
        startIndex: Int,
        endIndex: Int,
        brush: Brush,
        color: Color,
        erase: Bool
    ) {
        let blendMode: BlendMode = erase ?
            .erase : .normal
        
        let stampsToDraw = stamps[startIndex ..< endIndex]
        
        let sprites = stampsToDraw.map { stamp in
            SpriteRenderer.Sprite(
                size: Size(stamp.size, stamp.size),
                position: stamp.position,
                rotation: stamp.rotation,
                alpha: stamp.alpha)
        }
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            texture: brush.stampTexture,
            sprites: sprites,
            blendMode: blendMode,
            colorMode: .brush,
            color: color)
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
}
