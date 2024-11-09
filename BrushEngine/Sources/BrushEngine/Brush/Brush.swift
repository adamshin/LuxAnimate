
import Metal
import MetalKit
    
public struct BrushConfiguration: Sendable {
    
    public var shapeTextureName: String
    public var textureTextureName: String?
    
    public var stampSize: Double
    public var stampSpacing: Double
    public var stampAlpha: Double
    
    public var stampCount: Int
    public var stampPositionJitter: Double
    public var stampRotationJitter: Double
    public var stampSizeJitter: Double
    public var stampAlphaJitter: Double
    
    public var pressureSize: Double
    public var pressureStampAlpha: Double
    
    public var taperLength: Double
    public var taperRoundness: Double
    public var taperSize: Double
    
    public var sizeWobble: Double
    public var offsetWobble: Double
    public var wobbleFrequency: Double
    public var wobblePressureAttenuation: Double
    
    public var baseSmoothing: Double
    
    public init(
        shapeTextureName: String,
        textureTextureName: String?,
        stampSize: Double,
        stampSpacing: Double,
        stampAlpha: Double,
        stampCount: Int = 1,
        stampPositionJitter: Double = 0,
        stampRotationJitter: Double = 0,
        stampSizeJitter: Double = 0,
        stampAlphaJitter: Double = 0,
        pressureSize: Double,
        pressureStampAlpha: Double = 0,
        taperLength: Double,
        taperRoundness: Double,
        taperSize: Double = 0,
        sizeWobble: Double,
        offsetWobble: Double,
        wobbleFrequency: Double,
        wobblePressureAttenuation: Double,
        baseSmoothing: Double
    ) {
        self.shapeTextureName = shapeTextureName
        self.textureTextureName = textureTextureName
        self.stampSize = stampSize
        self.stampSpacing = stampSpacing
        self.stampAlpha = stampAlpha
        self.stampCount = stampCount
        self.stampPositionJitter = stampPositionJitter
        self.stampRotationJitter = stampRotationJitter
        self.stampSizeJitter = stampSizeJitter
        self.stampAlphaJitter = stampAlphaJitter
        self.pressureSize = pressureSize
        self.pressureStampAlpha = pressureStampAlpha
        self.taperLength = taperLength
        self.taperRoundness = taperRoundness
        self.taperSize = taperSize
        self.sizeWobble = sizeWobble
        self.offsetWobble = offsetWobble
        self.wobbleFrequency = wobbleFrequency
        self.wobblePressureAttenuation = wobblePressureAttenuation
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
