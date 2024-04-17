//
//  MetalBlitter.swift
//

import UIKit
import Metal

struct MetalBlitter {
    
    let metalInterface: MetalInterface
    
    func blit(_ src: MTLTexture, to dst: MTLTexture) {
        let commandBuffer = metalInterface.commandQueue.makeCommandBuffer()!
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: src, to: dst)
        blitEncoder.endEncoding()
        
        commandBuffer.commit()
    }
    
    func blit(_ texture: MTLTexture, to layer: CAMetalLayer) {
        guard let currentDrawable = layer.nextDrawable() else { return }
        
        let commandBuffer = metalInterface.commandQueue.makeCommandBuffer()!
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: texture, to: currentDrawable.texture)
        blitEncoder.endEncoding()
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
}
