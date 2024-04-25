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
            height: height,
            mipMapped: true)
        
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
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = targetWidth
        texDesc.height = targetHeight
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
            clearColor: Color(0, 0, 0, 0),
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
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * targetWidth
        let size = bytesPerRow * targetHeight
        
        let region = MTLRegionMake2D(
            0, 0, targetWidth, targetHeight)
        
        var data = Data(repeating: 0, count: size)
        
        data.withUnsafeMutableBytes { pointer in
            guard let baseAddress = pointer.baseAddress
            else { return }
            
            renderTarget.getBytes(
                baseAddress,
                bytesPerRow: bytesPerRow,
                from: region,
                mipmapLevel: 0)
        }
        
        return data
    }
    
}
