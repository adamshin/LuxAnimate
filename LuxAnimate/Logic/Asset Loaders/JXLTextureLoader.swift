//
//  JXLTextureLoader.swift
//

import Foundation
import Metal

struct JXLTextureLoader {
    
    static func load(
        url: URL,
        usage: MTLTextureUsage = .shaderRead
    ) throws -> MTLTexture {
        
        let encodedData = try Data(
            contentsOf: url)
        
        let output = try JXLDecoder.decode(
            data: encodedData)
        
        return try TextureCreator.createTexture(
            imageData: output.data,
            width: output.width,
            height: output.height)
    }
    
}
