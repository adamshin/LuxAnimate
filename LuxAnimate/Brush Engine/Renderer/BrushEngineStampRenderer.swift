//
//  BrushEngineStampRenderer.swift
//

import Metal
import Geometry

private let paddingSizeThreshold: Double = 20

struct BrushEngineStampRenderer {
    
    private let spriteRenderer = SpriteRenderer()
    
    func drawStamps(
        target: MTLTexture,
        viewportSize: Size,
        stamps: any Sequence<BrushEngine.Stamp>,
        brush: Brush,
        finalized: Bool
    ) {
        let sprites = stamps.map { s in
            let offsetPosition =
                s.position + s.offset * s.size
            
            let paddingScale: Double =
                s.size < paddingSizeThreshold ?
                3 : 1
            
            let color: Color
            if !finalized, AppConfig.brushRenderDebug {
                color = .debugRed
            } else {
                color = s.color
            }
            
            return SpriteRenderer.Sprite(
                position: offsetPosition,
                size: Size(s.size, s.size),
                rotation: s.rotation,
                color: color,
                alpha: s.alpha,
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
            colorMode: .brush)
        
        commandBuffer.commit()
    }
    
}
