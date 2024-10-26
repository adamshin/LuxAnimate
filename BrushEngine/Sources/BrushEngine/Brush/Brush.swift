
import Metal
import MetalKit

extension Brush {
    
    public struct Configuration: Sendable {
        
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
        
        public init(
            stampTextureName: String,
            stampSize: Double, stampSpacing: Double,
            stampAlpha: Double, pressureScaling: Double,
            taperLength: Double, taperRoundness: Double,
            sizeWobble: Double, offsetWobble: Double,
            wobbleFrequency: Double,
            wobblePressureAttenuation: Double,
            baseSmoothing: Double
        ) {
            self.stampTextureName = stampTextureName
            self.stampSize = stampSize
            self.stampSpacing = stampSpacing
            self.stampAlpha = stampAlpha
            self.pressureScaling = pressureScaling
            self.taperLength = taperLength
            self.taperRoundness = taperRoundness
            self.sizeWobble = sizeWobble
            self.offsetWobble = offsetWobble
            self.wobbleFrequency = wobbleFrequency
            self.wobblePressureAttenuation = wobblePressureAttenuation
            self.baseSmoothing = baseSmoothing
        }
        
    }
    
    enum LoadError: Error {
        case textureNotFound
    }
    
}

public struct Brush {
    
    public var configuration: Configuration
    public var stampTexture: MTLTexture
    
    public init(
        configuration c: Configuration,
        metalDevice: MTLDevice
    ) throws {
        
        self.configuration = c
        
        guard let stampTextureURL = Bundle.main.url(
            forResource: c.stampTextureName,
            withExtension: nil)
        else {
            throw LoadError.textureNotFound
        }
        
        let loader = MTKTextureLoader(device: metalDevice)
        
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
