//
//  ImageResizer.swift
//

import Foundation
import Metal

struct ImageResizer {
    
    private let spriteRenderer = SpriteRenderer()
    
    func resize(
        imageData: Data,
        width: Int,
        height: Int,
        targetWidth: Int,
        targetHeight: Int
    ) throws -> Data {
        
        let imageTexture = try TextureCreator.createTexture(
            imageData: imageData,
            width: width,
            height: height)
        
        return try resize(
            imageTexture: imageTexture,
            targetWidth: targetWidth,
            targetHeight: targetHeight)
    }
    
    func resize(
        imageTexture: MTLTexture,
        targetWidth: Int,
        targetHeight: Int
    ) throws -> Data {
        
        let renderTarget = RenderTarget(
            size: PixelSize(
                width: targetWidth,
                height: targetHeight))
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: renderTarget.texture,
            clearColor: Color(0, 0, 0, 0),
            viewportSize: Size(1, 1),
            texture: imageTexture,
            sprites: [
                SpriteRenderer.Sprite(
                    size: Size(1, 1),
                    position: Vector(0.5, 0.5))
            ],
            blendMode: .replace)
        
        commandBuffer.commit()
        
        return Data()
    }
    
}
