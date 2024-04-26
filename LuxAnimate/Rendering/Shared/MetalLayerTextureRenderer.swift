//
//  MetalLayerTextureRenderer.swift
//

import Foundation
import MetalKit

class MetalLayerTextureRenderer {
    
    private let spriteRenderer = SpriteRenderer(
        pixelFormat: .bgra8Unorm)
    
    func draw(
        texture: MTLTexture,
        to layer: CAMetalLayer
    ) {
        guard let drawable = layer.nextDrawable() else { return }
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: drawable.texture,
            viewportSize: Size(1, 1),
            texture: texture,
            sprites: [
                SpriteRenderer.Sprite(
                    size: Size(1, 1),
                    position: Vector(0.5, 0.5))
            ],
            blendMode: .replace,
            sampleMode: .nearest)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}
