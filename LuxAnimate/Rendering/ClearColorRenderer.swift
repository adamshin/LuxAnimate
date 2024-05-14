//
//  ClearColorRenderer.swift
//

import Foundation
import Metal

struct ClearColorRenderer {
    
    static func drawClearColor(
        commandBuffer: any MTLCommandBuffer,
        target: MTLTexture,
        color: Color
    ) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        
        let attachment = renderPassDescriptor.colorAttachments[0]!
        attachment.texture = target
        attachment.storeAction = .store
        attachment.loadAction = .clear
        attachment.clearColor = color.mtlClearColor
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor)!
         
        renderEncoder.endEncoding()
    }
    
}
