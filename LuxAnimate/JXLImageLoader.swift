//
//  JXLTextureLoader.swift
//

import Foundation
import Metal

struct JXLTextureLoader {
    
    enum Error: Swift.Error {
        case emptyData
    }
    
    static func load(
        url: URL,
        usage: MTLTextureUsage = .shaderRead
    ) throws -> MTLTexture {
        
        let data = try Data(contentsOf: url)
        let output = try JXLDecoder.decode(data: data)
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = output.width
        texDescriptor.height = output.height
        texDescriptor.pixelFormat = AppConfig.pixelFormat
        texDescriptor.usage = [.shaderRead]
        
        let texture = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
        
        let bytesPerPixel = 4
        let bytesPerRow = output.width * bytesPerPixel
        
        try output.data.withUnsafeBytes { bytes in
            guard let baseAddress = bytes.baseAddress
            else { throw Error.emptyData }
            
            let region = MTLRegionMake2D(
                0, 0,
                output.width,
                output.height)
            
            texture.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: baseAddress,
                bytesPerRow: bytesPerRow)
        }
        
        return texture
    }
    
}
