
import Foundation
import Geometry
import Color

private let minStampSize: Double = 0.5

private let pressureSensitivity: Double = 1.5

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
    
    func strokeSample(
        sample: Sample,
        strokeDistance: Double,
        strokeEndTime: TimeInterval
    ) -> Output {
        
        // Pressure
        let pressure = clamp(
            sample.pressure * pressureSensitivity,
            min: 0, max: 1)
        
        let pressureScaleFactor = 1
            + brush.configuration.pressureScaling
            * 2 * (pressure - 0.5)
        
        // Taper
        let (taperScaleFactor, isInTaperEnd) =
            combinedTaper(
                sampleTime: sample.time,
                strokeEndTime: strokeEndTime)
        
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
        
        let wobbleScaleFactor = 1
            + sizeWobble
            * brush.configuration.sizeWobble
            * wobbleIntensity
        
        // Stamp size
        let stampSizeUnclamped = baseStampSize
            * pressureScaleFactor
            * taperScaleFactor
            * wobbleScaleFactor
        
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
        
        let r = azimuthRotation * rollRotation
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
        
        // Stamp alpha
        let stampAlpha = brush.configuration.stampAlpha
        
        // Stroke sample
        let strokeSample = StrokeSample(
            position: sample.position,
            strokeDistance: strokeDistance,
            stampOffset: stampOffset,
            stampSize: stampSize,
            stampRotation: stampRotation,
            stampAlpha: stampAlpha)
        
        let isNonFinalized = isInTaperEnd
        
        return Output(
            strokeSample: strokeSample,
            isNonFinalized: isNonFinalized)
    }
    
    private func combinedTaper(
        sampleTime: TimeInterval,
        strokeEndTime: TimeInterval
    ) -> (Double, Bool) {
        
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
        
        let taperStartScale: Double
        let taperEndScale: Double
        let isInTaperEnd: Bool
        
        if normalizedDistanceToStart < 1 {
            taperStartScale = taperScale(
                for: normalizedDistanceToStart)
        } else {
            taperStartScale = 1
        }
        
        if normalizedDistanceToEnd < 1 {
            taperEndScale = taperScale(
                for: normalizedDistanceToEnd)
            isInTaperEnd = true
        } else {
            taperEndScale = 1
            isInTaperEnd = false
        }
        
        let taperScale = taperStartScale * taperEndScale
        
        return (taperScale, isInTaperEnd)
    }
    
    private func taperScale(
        for normalizedDistance: Double
    ) -> Double {
        let x = 1 - clamp(
            normalizedDistance,
            min: 0, max: 1)
        
        let s1 = 1 - x * x
        let s2 = sqrt(s1)
        
        let c2 = clamp(
            brush.configuration.taperRoundness,
            min: 0, max: 1)
        
        let c1 = 1 - c2
        
        return s1 * c1 + s2 * c2
    }
    
}
