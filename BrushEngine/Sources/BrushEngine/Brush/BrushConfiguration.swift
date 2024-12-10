
import Foundation

// MARK: - BrushConfiguration

public struct BrushConfiguration: Sendable {
    
    public enum StampRotationMode: Int, Sendable {
        case fixed = 0
        case azimuth = 1
        case azimuthAndRoll = 2
    }
    
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
    
}

extension BrushConfiguration {
    
    public init() {
        stampSize = 100
        stampSpacing = 0
        stampOpacity = 1
        stampCount = 1
        stampPositionJitter = 0
        stampRotationJitter = 0
        stampSizeJitter = 0
        stampOpacityJitter = 0
        pressureSize = 0
        pressureSizeGamma = 1
        pressureStampOpacity = 0
        pressureStampOpacityGamma = 1
        taperLength = 0
        taperRoundness = 0
        taperSize = 0
        sizeWobble = 0
        offsetWobble = 0
        wobbleFrequency = 0
        wobblePressureAttenuation = 0
        stampRotationMode = .fixed
        baseSmoothing = 0
    }
    
    public init(_ c: BrushConfigurationCodable) {
        self = BrushConfiguration()
        
        stampSize ?= c.stampSize
        stampSpacing ?= c.stampSpacing
        stampOpacity ?= c.stampOpacity
        stampCount ?= c.stampCount
        stampPositionJitter ?= c.stampPositionJitter
        stampRotationJitter ?= c.stampRotationJitter
        stampSizeJitter ?= c.stampSizeJitter
        stampOpacityJitter ?= c.stampOpacityJitter
        pressureSize ?= c.pressureSize
        pressureSizeGamma ?= c.pressureSizeGamma
        pressureStampOpacity ?= c.pressureStampOpacity
        pressureStampOpacityGamma ?= c.pressureStampOpacityGamma
        taperLength ?= c.taperLength
        taperRoundness ?= c.taperRoundness
        taperSize ?= c.taperSize
        sizeWobble ?= c.sizeWobble
        offsetWobble ?= c.offsetWobble
        wobbleFrequency ?= c.wobbleFrequency
        wobblePressureAttenuation ?= c.wobblePressureAttenuation
        stampRotationMode ?= c.stampRotationMode
            .flatMap { StampRotationMode(rawValue: $0) }
        baseSmoothing ?= c.baseSmoothing
    }
    
    public func codable() -> BrushConfigurationCodable {
        BrushConfigurationCodable(
            stampSize: stampSize,
            stampSpacing: stampSpacing,
            stampOpacity: stampOpacity,
            stampCount: stampCount,
            stampPositionJitter: stampPositionJitter,
            stampRotationJitter: stampRotationJitter,
            stampSizeJitter: stampSizeJitter,
            stampOpacityJitter: stampOpacityJitter,
            pressureSize: pressureSize,
            pressureSizeGamma: pressureSizeGamma,
            pressureStampOpacity: pressureStampOpacity,
            pressureStampOpacityGamma: pressureStampOpacityGamma,
            taperLength: taperLength,
            taperRoundness: taperRoundness,
            taperSize: taperSize,
            sizeWobble: sizeWobble,
            offsetWobble: offsetWobble,
            wobbleFrequency: wobbleFrequency,
            wobblePressureAttenuation: wobblePressureAttenuation,
            stampRotationMode: stampRotationMode.rawValue,
            baseSmoothing: baseSmoothing)
    }
    
}

// MARK: - BrushConfigurationCodable

public struct BrushConfigurationCodable: Codable {
    
    public var stampSize: Double?
    public var stampSpacing: Double?
    public var stampOpacity: Double?
    
    public var stampCount: Int?
    public var stampPositionJitter: Double?
    public var stampRotationJitter: Double?
    public var stampSizeJitter: Double?
    public var stampOpacityJitter: Double?
    
    public var pressureSize: Double?
    public var pressureSizeGamma: Double?
    public var pressureStampOpacity: Double?
    public var pressureStampOpacityGamma: Double?
    
    public var taperLength: Double?
    public var taperRoundness: Double?
    public var taperSize: Double?
    
    public var sizeWobble: Double?
    public var offsetWobble: Double?
    public var wobbleFrequency: Double?
    public var wobblePressureAttenuation: Double?
    
    public var stampRotationMode: Int?
    
    public var baseSmoothing: Double?
    
}

// MARK: - Utilities

infix operator ?= : AssignmentPrecedence
func ?= <T: Any> (left: inout T, right: T?) {
    if let right = right {
        left = right
    }
}
