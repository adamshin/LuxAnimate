
import Metal
import MetalKit

// TODO: Add parameters for pressure sensitivity (gamma)!
    
public struct BrushConfiguration: Sendable {
    
    public enum StampRotationMode: Sendable {
        case fixed
        case azimuth
        case azimuthAndRoll
    }
    
    public var shapeTextureName: String
    public var textureTextureName: String?
    
    public var stampSize: Double
    public var stampSpacing: Double
    public var stampOpacity: Double
    
    public var stampCount: Int
    public var stampPositionJitter: Double
    public var stampRotationJitter: Double
    public var stampSizeJitter: Double
    public var stampOpacityJitter: Double
    
    public var pressureSize: Double
    public var pressureSizeGamma: Double
    public var pressureStampOpacity: Double
    public var pressureStampOpacityGamma: Double
    
    public var taperLength: Double
    public var taperRoundness: Double
    public var taperSize: Double
    
    public var sizeWobble: Double
    public var offsetWobble: Double
    public var wobbleFrequency: Double
    public var wobblePressureAttenuation: Double
    
    public var stampRotationMode: StampRotationMode
    
    public var baseSmoothing: Double
    
    public init(
        shapeTextureName: String,
        textureTextureName: String?,
        stampSize: Double,
        stampSpacing: Double,
        stampOpacity: Double,
        stampCount: Int = 1,
        stampPositionJitter: Double = 0,
        stampRotationJitter: Double = 0,
        stampSizeJitter: Double = 0,
        stampOpacityJitter: Double = 0,
        pressureSize: Double,
        pressureSizeGamma: Double = 0.6,
        pressureStampOpacity: Double = 0,
        pressureStampOpacityGamma: Double = 0.6,
        taperLength: Double,
        taperRoundness: Double,
        taperSize: Double = 0,
        sizeWobble: Double,
        offsetWobble: Double,
        wobbleFrequency: Double,
        wobblePressureAttenuation: Double,
        stampRotationMode: StampRotationMode = .fixed,
        baseSmoothing: Double
    ) {
        self.shapeTextureName = shapeTextureName
        self.textureTextureName = textureTextureName
        self.stampSize = stampSize
        self.stampSpacing = stampSpacing
        self.stampOpacity = stampOpacity
        self.stampCount = stampCount
        self.stampPositionJitter = stampPositionJitter
        self.stampRotationJitter = stampRotationJitter
        self.stampSizeJitter = stampSizeJitter
        self.stampOpacityJitter = stampOpacityJitter
        self.pressureSize = pressureSize
        self.pressureSizeGamma = pressureSizeGamma
        self.pressureStampOpacity = pressureStampOpacity
        self.pressureStampOpacityGamma = pressureStampOpacityGamma
        self.taperLength = taperLength
        self.taperRoundness = taperRoundness
        self.taperSize = taperSize
        self.sizeWobble = sizeWobble
        self.offsetWobble = offsetWobble
        self.wobbleFrequency = wobbleFrequency
        self.wobblePressureAttenuation = wobblePressureAttenuation
        self.stampRotationMode = stampRotationMode
        self.baseSmoothing = baseSmoothing
    }
    
}
    
extension Brush {
    
    enum LoadError: Error {
        case textureNotFound
    }
    
}

public struct Brush {
    
    public var configuration: BrushConfiguration
    
    public var shapeTexture: MTLTexture
    public var textureTexture: MTLTexture?
    
    public init(
        configuration c: BrushConfiguration,
        metalDevice: MTLDevice
    ) throws {
        
        self.configuration = c
        
        guard let shapeTextureURL = Bundle.main.url(
            forResource: c.shapeTextureName,
            withExtension: nil)
        else {
            throw LoadError.textureNotFound
        }
        
        let loader = MTKTextureLoader(device: metalDevice)
        
        shapeTexture = try Self.loadTexture(
            loader: loader,
            url: shapeTextureURL)
        
        if let textureTextureName = c.textureTextureName {
            guard let textureTextureURL = Bundle.main.url(
                forResource: textureTextureName,
                withExtension: nil)
            else {
                throw LoadError.textureNotFound
            }
            
            textureTexture = try Self.loadTexture(
                loader: loader,
                url: textureTextureURL)
        } else {
            textureTexture = nil
        }
    }
    
    private static func loadTexture(
        loader: MTKTextureLoader,
        url: URL
    ) throws -> MTLTexture {
        
        return try loader.newTexture(
            URL: url,
            options: [
                .textureStorageMode: MTLStorageMode.private.rawValue,
                .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                .generateMipmaps: true,
                .SRGB: false,
            ])
    }
    
}
