
import Foundation
import Geometry
import Color

private let minStampDistance: Double = 1.0
private let minStampSize: Double = 0.5

private let maxTaperTime: TimeInterval = 0.2

private let pressureSensitivity: Double = 1.5

extension StrokeEngineStampGenerator {
    
    struct Output {
        var stamp: Stamp
        var distanceToNextStamp: Double
        var isNonFinalized: Bool
    }
    
}

struct StrokeEngineStampGenerator {
    
    let brush: Brush
    let color: Color
    let scale: Double
    let applyTaper: Bool
    
    let baseStampSize: Double
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        applyTaper: Bool
    ) {
        self.brush = brush
        self.color = color
        self.scale = scale
        self.applyTaper = applyTaper
        
        let maxStampSize = brush.configuration.stampSize
        
        baseStampSize = map(
            scale,
            in: (0, 1),
            to: (minStampSize, maxStampSize))
    }
    
    func stamp(
        sample: Sample,
        noiseSample: NoiseSample,
        strokeEndTime: TimeInterval
    ) -> Output {
        
        let pressure = clamp(
            sample.pressure * pressureSensitivity,
            min: 0, max: 1)
        
        let pressureScaleFactor = 1
            + brush.configuration.pressureScaling
            * 2 * (pressure - 0.5)
        
        let (taperScaleFactor, isInTaperEnd) =
            combinedTaper(
                sampleTime: sample.time,
                strokeEndTime: strokeEndTime)
        
        // TESTING
//        let wobbleIntensity = 1
//            - brush.config.wobblePressureAttenuation
//            * pow(pressure, 3)
        let wobbleIntensity = 1.0
        
        let wobbleScaleFactor = 1
            + noiseSample.sizeWobble
            * brush.configuration.sizeWobble
            * wobbleIntensity
        
        let stampSizeUnclamped = baseStampSize
            * pressureScaleFactor
            * taperScaleFactor
            * wobbleScaleFactor
        
        let stampSize = max(
            stampSizeUnclamped,
            minStampSize)
        
        let rotation = sample.azimuth + sample.roll
        
        let alpha = brush.configuration.stampAlpha
        
        let offsetX = noiseSample.offsetXWobble
            * brush.configuration.offsetWobble
            * wobbleIntensity
        
        let offsetY = noiseSample.offsetYWobble
            * brush.configuration.offsetWobble
            * wobbleIntensity
        
        var offset = Vector(offsetX, offsetY)
        if offset.lengthSquared() > 1.0 {
            offset = offset.normalized()
        }
        
        let stamp = BrushEngine.Stamp(
            position: sample.position,
            size: stampSize,
            rotation: rotation,
            alpha: alpha,
            color: color,
            offset: offset)
        
        let distanceToNextStamp = max(
            stampSize * brush.configuration.stampSpacing,
            minStampDistance)
        
        let isNonFinalized = isInTaperEnd
        
        return Output(
            stamp: stamp,
            distanceToNextStamp: distanceToNextStamp,
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
