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
        
        var sizeWobble: Double
        var offsetWobble: Double
        var wobbleFrequency: Double
        var wobblePressureAttenuation: Double
        
        var baseSmoothing: Double
    }
    
    enum LoadError: Error {
        case textureNotFound
    }
    
}

struct Brush {
    
    var config: Configuration
    var stampTexture: MTLTexture
    
    init(
        configuration c: Configuration
    ) throws {
        
        self.config = c
        
        guard let stampTextureURL = Bundle.main.url(
            forResource: c.stampTextureName,
            withExtension: nil)
        else {
            throw LoadError.textureNotFound
        }
        
        let loader = MTKTextureLoader(
            device: MetalInterface.shared.device)
        
        stampTexture = try loader.newTexture(
            URL: stampTextureURL,
            options: [
                .textureStorageMode: MTLStorageMode.private.rawValue,
                .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                .generateMipmaps: true,
                .SRGB: false,
            ])
    }
    
}
