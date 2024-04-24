//
//  TextureCreator.swift
//

import Foundation
import Metal

struct TextureCreator {
    
    enum Error: Swift.Error {
        case emptyData
    }
    
    static func createTexture(
        imageData: Data,
        width: Int,
        height: Int
    ) throws -> MTLTexture {
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = width
        texDescriptor.height = height
        texDescriptor.pixelFormat = AppConfig.pixelFormat
        texDescriptor.usage = [.shaderRead]
        
        let texture = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        
        try imageData.withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress
            else { throw Error.emptyData }
            
            let region = MTLRegionMake2D(
                0, 0, width, height)
            
            texture.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: baseAddress,
                bytesPerRow: bytesPerRow)
        }
        
        return texture
    }
    
}
