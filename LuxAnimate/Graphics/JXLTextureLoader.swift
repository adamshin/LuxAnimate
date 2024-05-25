//
//  JXLTextureLoader.swift
//

import Foundation
import Metal

struct JXLTextureLoader {
    
    static func load(
        url: URL,
        mipMapped: Bool = false,
        usage: MTLTextureUsage = .shaderRead
    ) throws -> MTLTexture {
        
        let encodedData = try Data(
            contentsOf: url)
        
        let output = try JXLDecoder.decode(
            data: encodedData,
            progress: { true })
        
        return try TextureCreator.createTexture(
            imageData: output.data,
            size: PixelSize(
                width: output.width,
                height: output.height),
            mipMapped: mipMapped,
            usage: usage)
    }
    
}
