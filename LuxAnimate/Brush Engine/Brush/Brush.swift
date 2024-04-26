//
//  Brush.swift
//

import Metal
import MetalKit

struct Brush {
    
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
    
    var stampSize: Double
    var stampSpacing: Double
    var stampAlpha: Double
    
    var pressureScaling: Double
    
    var taperLength: Double
    var taperRoundness: Double
    
    var stampTexture: MTLTexture
    
    init(
        configuration c: Configuration
    ) throws {
        
        stampSize = c.stampSize
        stampSpacing = c.stampSpacing
        stampAlpha = c.stampAlpha
        
        pressureScaling = c.pressureScaling
        
        taperLength = c.taperLength
        taperRoundness = c.taperRoundness
        
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
                .generateMipmaps: true
            ])
    }
    
}
