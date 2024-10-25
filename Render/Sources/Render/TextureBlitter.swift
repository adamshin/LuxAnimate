//
//  TextureBlitter.swift
//

import Metal

public struct TextureBlitter {
    
    enum Error: Swift.Error {
        case differentTextureSizes
    }
    
    private let commandQueue: MTLCommandQueue
    
    public init(commandQueue: MTLCommandQueue) {
        self.commandQueue = commandQueue
    }
    
    public func blit(
        from src: MTLTexture,
        to dst: MTLTexture,
        waitUntilCompleted: Bool = false
    ) throws {
        
        guard src.width == dst.width,
            src.height == dst.height
        else { throw Error.differentTextureSizes }
        
        let commandBuffer = commandQueue
            .makeCommandBuffer()!
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: src, to: dst)
        blitEncoder.endEncoding()
        
        commandBuffer.commit()
        
        if waitUntilCompleted {
            commandBuffer.waitUntilCompleted()
        }
    }
    
}
