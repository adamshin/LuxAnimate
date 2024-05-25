//
//  ImageResizer.swift
//

import Foundation
import Metal

struct ImageResizer {
    
    private let spriteRenderer = SpriteRenderer()
    
    func resize(
        imageData: Data,
        size: PixelSize,
        targetSize: PixelSize
    ) throws -> Data {
        
        let imageTexture = try TextureCreator.createTexture(
            imageData: imageData,
            size: size,
            mipMapped: true)
        
        return try resize(
            imageTexture: imageTexture,
            targetSize: targetSize)
    }
    
    func resize(
        imageTexture: MTLTexture,
        targetSize: PixelSize
    ) throws -> Data {
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = targetSize.width
        texDesc.height = targetSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .shared
        texDesc.usage = .renderTarget
        
        let renderTarget = MetalInterface.shared.device
            .makeTexture(descriptor: texDesc)!
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: renderTarget,
            viewportSize: Size(1, 1),
            texture: imageTexture,
            sprites: [
                SpriteRenderer.Sprite(
                    size: Size(1, 1),
                    position: Vector(0.5, 0.5))
            ],
            blendMode: .replace,
            sampleMode: .linear)
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let data = try TextureDataReader.read(renderTarget)
        return data
    }
    
}
