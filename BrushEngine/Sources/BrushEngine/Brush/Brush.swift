
import Metal

// MARK: - Brush

public struct Brush {
    
    public var id: String
    public var metadata: BrushMetadata
    public var configuration: BrushConfiguration
    
    public var shapeTexture: MTLTexture
    public var grainTexture: MTLTexture?
    
}

// MARK: - Brush Metadata

public struct BrushMetadata: Codable, Sendable {
    
    public var name: String
    
}

// MARK: - Brush Configuration

public struct BrushConfiguration: Codable, Sendable {
    
    public enum StampRotationMode: Int, Codable, Sendable {
        case fixed = 0
        case azimuth = 1
        case azimuthAndRoll = 2
    }
    
    public var stampSize: Double = 100
    public var stampSpacing: Double = 0
    public var stampOpacity: Double = 1
    
    public var stampCount: Int = 1
    public var stampPositionJitter: Double = 0
    public var stampRotationJitter: Double = 0
    public var stampSizeJitter: Double = 0
    public var stampOpacityJitter: Double = 0
    
    public var pressureSize: Double = 0
    public var pressureSizeGamma: Double = 1
    public var pressureStampOpacity: Double = 0
    public var pressureStampOpacityGamma: Double = 1
    
    public var taperLength: Double = 0
    public var taperRoundness: Double = 0
    public var taperSize: Double = 0
    
    public var sizeWobble: Double = 0
    public var offsetWobble: Double = 0
    public var wobbleFrequency: Double = 0
    public var wobblePressureAttenuation: Double = 0
    
    public var stampRotationMode: StampRotationMode = .fixed
    
    public var baseSmoothing: Double = 0
    
}
