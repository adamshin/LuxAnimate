//
//  BrushStrokeStampProcessor.swift
//

import Foundation

private let minStampDistance: Double = 1.0
private let minStampSize: Double = 0.5

private let maxTaperTime: TimeInterval = 0.2

private let pressureSensitivity: Double = 1.5

private let wobbleOctaveCount = 2
private let wobblePersistence: Double = 0.5

private let maxStampsPerUpdate = 2000

class BrushStrokeStampProcessor {
    
    struct State {
        var stamps: [BrushStrokeEngine.Stamp]
        
        var segmentIndex: Int
        var lastStampDistanceAlongSegment: Double
        
        var isFinalized: Bool
    }
    
    private let brush: Brush
    private let scale: Double
    private let ignoreTaper: Bool
    
    private let sizeWobbleGenerator: PerlinNoiseGenerator
    private let offsetXWobbleGenerator: PerlinNoiseGenerator
    private let offsetYWobbleGenerator: PerlinNoiseGenerator
    
    private var lastFinalizedState: State
    
    init(
        brush: Brush,
        scale: Double,
        ignoreTaper: Bool
    ) {
        self.brush = brush
        self.scale = scale
        self.ignoreTaper = ignoreTaper
        
        sizeWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.config.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
        
        offsetXWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.config.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
        
        offsetYWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.config.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
        
        lastFinalizedState = State(
            stamps: [],
            segmentIndex: 0,
            lastStampDistanceAlongSegment: 0,
            isFinalized: true)
    }
        
    func process(
        samples: [BrushStrokeEngine.Sample]
    ) -> [BrushStrokeEngine.Stamp] {
        
        guard !samples.isEmpty else { return [] }
        
        let firstSample = samples.first!
        let lastSample = samples.last!
        let endTime = lastSample.time
        
        var state = lastFinalizedState
        
        if state.stamps.isEmpty {
            let firstStamp = stamp(
                strokeDistance: 0,
                sample: firstSample,
                endTime: endTime)
            
            state.stamps.append(firstStamp)
        }
        
        var addedStampCount = 0
        
        while state.segmentIndex < samples.count - 1 {
            let segmentStartSample = samples[state.segmentIndex]
            let segmentEndSample = samples[state.segmentIndex + 1]
            
            let segmentStartToEnd =
                segmentEndSample.position -
                segmentStartSample.position
            
            let segmentLength = segmentStartToEnd.length()
            
            while true {
                let prevStamp = state.stamps.last!
                
                let distanceToNextStamp = max(
                    prevStamp.size * brush.config.stampSpacing,
                    minStampDistance)
                
                let nextStampDistanceAlongSegment =
                    state.lastStampDistanceAlongSegment +
                    distanceToNextStamp
                
                if nextStampDistanceAlongSegment > segmentLength {
                    state.segmentIndex += 1
                    state.lastStampDistanceAlongSegment -= segmentLength
                    break
                }
                
                let strokeDistance = prevStamp.strokeDistance + distanceToNextStamp
                
                let progressBetweenSamples = nextStampDistanceAlongSegment / segmentLength
                
                let interpolatedSample = Self.interpolatedSample(
                    progressBetweenSamples: progressBetweenSamples,
                    sample1: segmentStartSample,
                    sample2: segmentEndSample)
                
                let stamp = stamp(
                    strokeDistance: strokeDistance,
                    sample: interpolatedSample,
                    endTime: endTime)
                
                state.stamps.append(stamp)
                state.lastStampDistanceAlongSegment = nextStampDistanceAlongSegment
                
                state.isFinalized = state.isFinalized && stamp.isFinalized
                
                if state.isFinalized {
                    lastFinalizedState = state
                }
                
                addedStampCount += 1
                if addedStampCount > maxStampsPerUpdate {
                    break
                }
            }
            if addedStampCount > maxStampsPerUpdate {
                break
            }
        }
        
        return state.stamps
    }
    
    private static func interpolatedSample(
        progressBetweenSamples: Double,
        sample1 s1: BrushStrokeEngine.Sample,
        sample2 s2: BrushStrokeEngine.Sample
    ) -> BrushStrokeEngine.Sample {
        
        let c1 = 1 - progressBetweenSamples
        let c2 = progressBetweenSamples
        
        let time = c1 * s1.time + c2 * s2.time
        let position = c1 * s1.position + c2 * s2.position
        let pressure = c1 * s1.pressure + c2 * s2.pressure
        let altitude = c1 * s1.altitude + c2 * s2.altitude
        let azimuth = c1 * s1.azimuth + c2 * s2.azimuth
        
        let isFinalized = s1.isFinalized && s2.isFinalized
        
        return BrushStrokeEngine.Sample(
            time: time,
            position: position,
            pressure: pressure,
            altitude: altitude,
            azimuth: azimuth,
            isFinalized: isFinalized)
    }
    
    private func stamp(
        strokeDistance: Double,
        sample: BrushStrokeEngine.Sample,
        endTime: TimeInterval
    ) -> BrushStrokeEngine.Stamp {
        
        let scaledBrushSize = map(
            scale,
            in: (0, 1),
            to: (minStampSize, brush.config.stampSize))
        
        let pressure = clamp(
            sample.pressure * pressureSensitivity,
            min: 0, max: 1)
        
        let pressureScale = 1
            + brush.config.pressureScaling
            * 2 * (pressure - 0.5)
        
        let (taperScale, isInTaperEnd) = combinedTaper(
            sampleTime: sample.time,
            endTime: endTime)
        
        let wobbleDistance = strokeDistance / scaledBrushSize
        let wobbleIntensity = 1
            - brush.config.wobblePressureAttenuation
            * pow(pressure, 3)
        
        let sizeWobbleValue = sizeWobbleGenerator
            .value(at: wobbleDistance)
        let wobbleScale = 1 
            + brush.config.sizeWobble
            * sizeWobbleValue
            * wobbleIntensity
        
        let size = scaledBrushSize
            * pressureScale
            * taperScale
            * wobbleScale
        
        let clampedSize = max(size, minStampSize)
        
        let rotation = Self.rotation(from: sample.azimuth)
        
        let alpha = brush.config.stampAlpha
        
        let offsetX = offsetXWobbleGenerator.value(at: wobbleDistance)
            * brush.config.offsetWobble
            * wobbleIntensity
        let offsetY = offsetYWobbleGenerator.value(at: wobbleDistance)
            * brush.config.offsetWobble
            * wobbleIntensity
        
        var offset = Vector(offsetX, offsetY)
        if offset.lengthSquared() > 1.0 {
            offset = offset.normalized()
        }
        
        let isFinalized = sample.isFinalized && !isInTaperEnd
        
        return BrushStrokeEngine.Stamp(
            size: clampedSize,
            position: sample.position,
            rotation: rotation,
            alpha: alpha,
            offset: offset,
            strokeDistance: strokeDistance,
            isFinalized: isFinalized)
    }
    
    private static func rotation(
        from azimuth: Vector
    ) -> Double {
        
        if azimuth.lengthSquared() < 0.0001 {
            return 0
        }
        return atan2(azimuth.y, azimuth.x) - .halfPi
    }
    
    private func combinedTaper(
        sampleTime: TimeInterval,
        endTime: TimeInterval
    ) -> (Double, Bool) {
        
        let taperTime: TimeInterval
        
        if ignoreTaper {
            taperTime = 0
        } else {
            taperTime =
                clamp(brush.config.taperLength, min: 0, max: 1)
                * maxTaperTime
        }
        
        let normalizedDistanceToStart = sampleTime / taperTime
        let normalizedDistanceToEnd = (endTime - sampleTime) / taperTime
        
        let taperStartScale: Double
        let taperEndScale: Double
        let isInTaperStart: Bool
        let isInTaperEnd: Bool
        
        if normalizedDistanceToStart < 1 {
            taperStartScale = taperScale(for: normalizedDistanceToStart)
            isInTaperStart = true
        } else {
            taperStartScale = 1
            isInTaperStart = false
        }
        
        if normalizedDistanceToEnd < 1 {
            taperEndScale = taperScale(for: normalizedDistanceToEnd)
            isInTaperEnd = true
        } else {
            taperEndScale = 1
            isInTaperEnd = false
        }
        
        let taperScale: Double
        if isInTaperStart || isInTaperEnd {
            taperScale = taperStartScale * taperEndScale
        } else {
            taperScale = 1
        }
        
        return (taperScale, isInTaperEnd)
    }
    
    private func taperScale(
        for normalizedDistance: Double
    ) -> Double {
        let x = 1 - clamp(normalizedDistance, min: 0, max: 1)
        let s1 = 1 - x * x
        let s2 = sqrt(s1)
        
        let c2 = clamp(brush.config.taperRoundness, min: 0, max: 1)
        let c1 = 1 - c2
        
        return s1 * c1 + s2 * c2
    }
    
}
