
import Foundation
import Geometry
import Color

private let minStampSize: Double = 0.5

private let pressureScale: Double = 1.0
private let pressurePower: Double = 0.6

private let maxTaperTime: TimeInterval = 0.2

private let wobbleOctaveCount = 2
private let wobblePersistence: Double = 0.5

extension StrokeSampleGenerator {
    
    struct Output {
        var strokeSample: StrokeSample
        var isNonFinalized: Bool
    }
    
}

struct StrokeSampleGenerator {
    
    private let brush: Brush
    private let applyTaper: Bool
    
    private let baseStampSize: Double
    
    private let sizeWobbleGenerator: PerlinNoiseGenerator
    private let offsetXWobbleGenerator: PerlinNoiseGenerator
    private let offsetYWobbleGenerator: PerlinNoiseGenerator
    
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
        
        offsetXWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.configuration.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
        
        offsetYWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.configuration.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
    }
    
    // MARK: - Interface
    
    func strokeSample(
        sample: Sample,
        strokeDistance: Double,
        strokeEndTime: TimeInterval
    ) -> Output {
        
        // Pressure
        let clampedPressure = clamp(
            sample.pressure * pressureScale,
            min: 0, max: 1)
        
        let pressure = pow(clampedPressure, pressurePower)
        
        let pressureSize = 1
            - brush.configuration.pressureSize
            * (1 - pressure)
        
        let pressureOpacity = 1
            - brush.configuration.pressureStampOpacity
            * (1 - pressure)
        
        // Taper
        let (taperAmount, isInTaperEnd) =
            Self.combinedTaper(
                brush: brush,
                applyTaper: applyTaper,
                sampleTime: sample.time,
                strokeEndTime: strokeEndTime)
        
        let taperSize = 1
            - (1 - taperAmount)
            * brush.configuration.taperSize
        
        // Wobble
        let wobbleDistance = strokeDistance / baseStampSize
        
        let sizeWobble = sizeWobbleGenerator
            .value(at: wobbleDistance)
        let offsetXWobble = offsetXWobbleGenerator
            .value(at: wobbleDistance)
        let offsetYWobble = offsetYWobbleGenerator
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
            * pressureSize
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
        let offsetX = offsetXWobble
            * brush.configuration.offsetWobble
            * wobbleIntensity
        
        let offsetY = offsetYWobble
            * brush.configuration.offsetWobble
            * wobbleIntensity
        
        var stampOffset = Vector(offsetX, offsetY)
        if stampOffset.lengthSquared() > 1.0 {
            stampOffset = stampOffset.normalized()
        }
        
        // Stamp opacity
        let stampOpacity = brush.configuration.stampOpacity
            * pressureOpacity
        
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
        strokeEndTime: TimeInterval
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
        
        let normalizedDistanceToStart =
            sampleTime / taperTime
        
        let normalizedDistanceToEnd =
            (strokeEndTime - sampleTime)
            / taperTime
        
        let taperStartAmount: Double
        let taperEndAmount: Double
        let isInTaperEnd: Bool
        
        if normalizedDistanceToStart < 1 {
            taperStartAmount = taperAmount(
                roundness: roundness,
                distance: normalizedDistanceToStart)
        } else {
            taperStartAmount = 1
        }
        
        if normalizedDistanceToEnd < 1 {
            taperEndAmount = taperAmount(
                roundness: roundness,
                distance: normalizedDistanceToEnd)
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
