//
//  TextureBlitter.swift
//

import Metal

struct TextureBlitter {
    
    enum Error: Swift.Error {
        case differentTextureSizes
    }
    
    static func blit(
        from src: MTLTexture,
        to dst: MTLTexture
    ) throws {
        
        guard src.width == dst.width,
            src.height == dst.height
        else { throw Error.differentTextureSizes }
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: src, to: dst)
        blitEncoder.endEncoding()
        
        commandBuffer.commit()
    }
    
}
