//
//  BrushEngineStampRenderer.swift
//

import Metal

private let paddingSizeThreshold: Double = 20

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
            let paddingScale: Double =
                stamp.size < paddingSizeThreshold ?
                3 : 1
            
            return SpriteRenderer.Sprite(
                size: Size(stamp.size, stamp.size),
                position: stamp.position,
                rotation: stamp.rotation,
                alpha: stamp.alpha,
                paddingScale: paddingScale)
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
            sampleMode: .linearClampEdgeToBlack,
            colorMode: .brush,
            color: color)
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
}
