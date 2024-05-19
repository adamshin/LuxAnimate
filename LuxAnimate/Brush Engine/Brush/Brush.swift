//
//  Brush.swift
//

import Metal
import MetalKit

extension Brush {
    
    struct Configuration {
        var stampTextureName: String
        var stampSize: Double
        var stampSpacing: Double
        var stampAlpha: Double
        
        var pressureScaling: Double
        
        var taperLength: Double
        var taperRoundness: Double
    }
    
    enum LoadError: Error {
        case textureNotFound
    }
    
}

struct Brush {
    
    var configuration: Configuration
    var stampTexture: MTLTexture
    
    init(
        configuration c: Configuration
    ) throws {
        
        self.configuration = c
        
        guard let stampTextureURL = Bundle.main.url(
            forResource: c.stampTextureName,
            withExtension: nil)
        else {
            throw LoadError.textureNotFound
        }
        
        // TODO: fix sRGB gamma issue?
        let loader = MTKTextureLoader(
            device: MetalInterface.shared.device)
        
        stampTexture = try loader.newTexture(
            URL: stampTextureURL,
            options: [
                .textureStorageMode: MTLStorageMode.private.rawValue,
                .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                .generateMipmaps: true,
//                .SRGB: true,
            ])
    }
    
}
