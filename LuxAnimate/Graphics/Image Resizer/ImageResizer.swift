//
//  ImageResizer.swift
//

import Foundation
import Metal

struct ImageResizer {
    
    private let spriteRenderer = SpriteRenderer()
    
    static func resize(
        imageData: Data,
        width: Int,
        height: Int,
        targetWidth: Int,
        targetHeight: Int
    ) throws -> Data {
        
        let renderTarget = RenderTarget(
            size: PixelSize(
                width: targetWidth,
                height: targetHeight))
        
        // TODO
        
        return Data()
    }
    
}
