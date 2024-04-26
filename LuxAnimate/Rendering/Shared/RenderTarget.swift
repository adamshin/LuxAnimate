//
//  RenderTarget.swift
//

import Foundation
import Metal

struct RenderTarget {
    
    let texture: MTLTexture
    
    init(size: PixelSize) {
        let texDesc = MTLTextureDescriptor()
        texDesc.width = size.width
        texDesc.height = size.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .private
        texDesc.usage = [.renderTarget, .shaderRead]
        
        texture = MetalInterface.shared.device
            .makeTexture(descriptor: texDesc)!
    }
    
}
