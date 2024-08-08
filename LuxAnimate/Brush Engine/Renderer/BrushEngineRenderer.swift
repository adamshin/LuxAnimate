//
//  BrushEngineRenderer.swift
//

import Foundation
import Metal

class BrushEngineRenderer {
    
    private let strokeBlendMode: BlendMode
    private let spriteRenderer = SpriteRenderer()
    
    let renderTarget: MTLTexture
    
    init(
        canvasSize: PixelSize,
        brushMode: BrushEngine.BrushMode
    ) {
        strokeBlendMode = switch brushMode {
        case .paint: .normal
        case .erase: .erase
        }
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = canvasSize.width
        texDesc.height = canvasSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .shared
        texDesc.usage = [.renderTarget, .shaderRead]
        
        renderTarget = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
    }
    
    func draw(
        baseCanvasTexture: MTLTexture?,
        strokeTexture: MTLTexture
    ) {
        if let baseCanvasTexture {
            try? TextureBlitter.blit(
                from: baseCanvasTexture,
                to: renderTarget)
        }
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: renderTarget,
            viewportSize: Size(1, 1),
            texture: strokeTexture,
            sprites: [
                SpriteRenderer.Sprite(
                    position: Vector(0.5, 0.5),
                    size: Size(1, 1))
            ],
            blendMode: strokeBlendMode,
            sampleMode: .nearest)
        
        commandBuffer.commit()
    }
    
}
