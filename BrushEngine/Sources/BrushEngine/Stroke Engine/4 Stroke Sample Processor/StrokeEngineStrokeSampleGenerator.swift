
import Foundation
import Geometry
import Color

private let minStampSize: Double = 0.5

private let pressureScale: Double = 1.0

private let maxTaperTime: TimeInterval = 0.2

private let wobbleOctaveCount = 2
private let wobblePersistence: Double = 0.5

extension StrokeEngineStrokeSampleGenerator {
    
    struct Output {
        var strokeSample: StrokeSample
        var isNonFinalized: Bool
    }
    
}

struct StrokeEngineStrokeSampleGenerator {
    
    private let brush: Brush
    private let applyTaper: Bool
    
    private let baseStampSize: Double
    
    private let sizeWobbleGenerator: PerlinNoiseGenerator
    private let offsetWobbleGenerator: PerlinNoiseGenerator
    
    // MARK: - Init
    
    init(
        brush: Brush,
        scale: Double,
        applyTaper: Bool
    ) {
        self.brush = brush
        self.applyTaper = applyTaper
        
        let maxStampSize = brush.configuration.stampSize
        
        baseStampSize = map(scale,
            in: (0, 1),
            to: (minStampSize, maxStampSize))
        
        sizeWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.configuration.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)

        offsetWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.configuration.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
    }
    
    // MARK: - Interface
    
    func strokeSample(
        sample: IntermediateSample,
        tangent: Vector,
        strokeDistance: Double,
        finalSampleTime: TimeInterval
    ) -> Output {
        
        // Pressure
        let pressure = clamp(
            sample.pressure * pressureScale,
            min: 0, max: 1)
        
        let pressureSize = pow(
            pressure,
            brush.configuration.pressureSizeGamma)
        
        let pressureStampOpacity = pow(
            pressure,
            brush.configuration.pressureStampOpacityGamma)
        
        let pressureSizeFactor = 1
            - brush.configuration.pressureSize
            * (1 - pressureSize)
        
        let pressureOpacityFactor = 1
            - brush.configuration.pressureStampOpacity
            * (1 - pressureStampOpacity)
        
        // Taper
        let (taperAmount, isInTaperEnd) =
            Self.combinedTaper(
                brush: brush,
                applyTaper: applyTaper,
                sampleTime: sample.time,
                finalSampleTime: finalSampleTime)
        
        let taperSize = 1
            - (1 - taperAmount)
            * brush.configuration.taperSize
        
        // Wobble
        let wobbleDistance = strokeDistance / baseStampSize
        
        let sizeWobble = sizeWobbleGenerator
            .value(at: wobbleDistance)
        let offsetWobble = offsetWobbleGenerator
            .value(at: wobbleDistance)
        
        let wobbleIntensity = 1
            - brush.configuration.wobblePressureAttenuation
            * pow(pressure, 3)
        
        let wobbleSize = 1
            + sizeWobble
            * brush.configuration.sizeWobble
            * wobbleIntensity
        
        // Stamp size
        let stampSizeUnclamped = baseStampSize
            * pressureSizeFactor
            * taperSize
            * wobbleSize
        
        let stampSize = max(
            stampSizeUnclamped,
            minStampSize)
        
        // Stamp rotation
        let azimuthRotation: Complex
        if sample.azimuth.isZero {
            azimuthRotation = .one
        } else {
            azimuthRotation = sample.azimuth * -.i
        }
        
        let rollRotation: Complex
        if sample.roll.isZero {
            rollRotation = .one
        } else {
            rollRotation = sample.roll
        }
        
        let r: Complex
        switch brush.configuration.stampRotationMode {
        case .fixed:
            r = .one
        case .azimuth:
            r = azimuthRotation
        case .azimuthAndRoll:
            r = azimuthRotation * rollRotation
        }
        let stampRotation = r.normalized()
        
        // Stamp offset
        let perpendicular = tangent.perpendicularClockwise
        
        let offsetWobbleMagnitude = offsetWobble
            * brush.configuration.offsetWobble
            * wobbleIntensity
        
        let stampOffset =
            perpendicular * offsetWobbleMagnitude
        
        // Stamp opacity
        let stampOpacity = brush.configuration.stampOpacity
            * pressureOpacityFactor
        
        // Stroke sample
        let strokeSample = StrokeSample(
            position: sample.position,
            strokeDistance: strokeDistance,
            stampOffset: stampOffset,
            stampSize: stampSize,
            stampRotation: stampRotation,
            stampOpacity: stampOpacity)
        
        let isNonFinalized = isInTaperEnd
        
        return Output(
            strokeSample: strokeSample,
            isNonFinalized: isNonFinalized)
    }
    
    // MARK: - Taper
    
    private static func combinedTaper(
        brush: Brush,
        applyTaper: Bool,
        sampleTime: TimeInterval,
        finalSampleTime: TimeInterval
    ) -> (Double, Bool) {
        
        let roundness = brush.configuration.taperRoundness
        let taperTime: TimeInterval
        
        if !applyTaper {
            taperTime = 0
        } else {
            let taperLength = clamp(
                brush.configuration.taperLength,
                min: 0, max: 1)
            taperTime = taperLength * maxTaperTime
        }
        
        let normalizedTimeDistanceToStart =
            sampleTime / taperTime
        
        let normalizedTimeDistanceToEnd =
            (finalSampleTime - sampleTime)
            / taperTime
        
        let taperStartAmount: Double
        let taperEndAmount: Double
        let isInTaperEnd: Bool
        
        if normalizedTimeDistanceToStart < 1 {
            taperStartAmount = taperAmount(
                roundness: roundness,
                distance: normalizedTimeDistanceToStart)
        } else {
            taperStartAmount = 1
        }
        
        if normalizedTimeDistanceToEnd < 1 {
            taperEndAmount = taperAmount(
                roundness: roundness,
                distance: normalizedTimeDistanceToEnd)
            isInTaperEnd = true
        } else {
            taperEndAmount = 1
            isInTaperEnd = false
        }
        
        let taperAmount = taperStartAmount * taperEndAmount
        
        return (taperAmount, isInTaperEnd)
    }
    
    private static func taperAmount(
        roundness: Double,
        distance: Double
    ) -> Double {
        let d = clamp(distance, min: 0, max: 1)
        let x = 1 - d
        
        let r = clamp(roundness, min: 0, max: 1)
        let n = map(r, in: (0, 1), to: (1, 0.3))
        
        return pow(1 - x*x, n)
    }
    
}
