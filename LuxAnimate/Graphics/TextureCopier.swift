//
//  TextureCopier.swift
//

import Metal
import Render

struct TextureCopier {
    
    enum Error: Swift.Error {
        case unknown
    }
    
    private let textureBlitter = TextureBlitter(
        commandQueue: MetalInterface.shared.commandQueue)
    
    func copy(
        _ texture: MTLTexture,
        usage: MTLTextureUsage = .shaderRead
    ) throws -> MTLTexture {
        
        let desc = MTLTextureDescriptor()
        desc.textureType = texture.textureType
        desc.pixelFormat = texture.pixelFormat
        desc.width = texture.width
        desc.height = texture.height
        desc.mipmapLevelCount = texture.mipmapLevelCount
        desc.sampleCount = texture.sampleCount
        
        desc.usage = usage
        
        let newTexture = MetalInterface.shared.device
            .makeTexture(descriptor: desc)!
        
        try textureBlitter.blit(
            from: texture,
            to: newTexture,
            waitUntilCompleted: true)
        
        return newTexture
    }
    
}
