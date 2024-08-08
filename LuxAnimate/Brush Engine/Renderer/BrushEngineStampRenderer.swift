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
        color: Color
    ) { 
        let stampsToDraw = stamps[startIndex ..< endIndex]
        
        let sprites = stampsToDraw.map { stamp in
            let offsetPosition = stamp.position
                + stamp.offset * stamp.size
            
            let paddingScale: Double =
                stamp.size < paddingSizeThreshold ?
                3 : 1
            
            return SpriteRenderer.Sprite(
                position: offsetPosition,
                size: Size(stamp.size, stamp.size),
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
            blendMode: .normal,
            sampleMode: .linearClampEdgeToBlack,
            colorMode: .brush,
            color: color)
        
        commandBuffer.commit()
    }
    
}
