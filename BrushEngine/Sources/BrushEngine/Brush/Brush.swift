
import Metal
import MetalKit

extension Brush {
    
    public struct Configuration {
        public var id: String
        public var name: String
        
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
        
        public var stampTextureID: String
    }
    
}

public struct Brush {
    
    public var configuration: Configuration
    public var textures: [String: MTLTexture]
    
    init(
        configuration: Configuration,
        textures: [String: MTLTexture]
    ) {
        self.configuration = configuration
        self.textures = textures
    }
    
}
