
import Metal
import MetalKit

extension Brush {
    
    public struct Configuration {
        public var stampTextureName: String
        public var stampSize: Double
        public var stampSpacing: Double
        public var stampAlpha: Double
        
        public var pressureScaling: Double
        
        public var taperLength: Double
        public var taperRoundness: Double
        
        public var sizeWobble: Double
        public var offsetWobble: Double
        public var wobbleFrequency: Double
        public var wobblePressureAttenuation: Double
        
        public var baseSmoothing: Double
    }
    
    public enum LoadError: Error {
        case textureNotFound
    }
    
}

public struct Brush {
    
    public var config: Configuration
    public var stampTexture: MTLTexture
    
    init(
        configuration c: Configuration,
        mtlDevice: MTLDevice
    ) throws {
        
        self.config = c
        
        guard let stampTextureURL = Bundle.main.url(
            forResource: c.stampTextureName,
            withExtension: nil)
        else {
            throw LoadError.textureNotFound
        }
        
        let loader = MTKTextureLoader(
            device: mtlDevice)
        
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
