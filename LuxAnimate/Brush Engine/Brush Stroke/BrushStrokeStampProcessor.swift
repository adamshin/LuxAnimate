//
//  BrushStrokeStampProcessor.swift
//

import Foundation

private let minStampDistance: Double = 1.0
private let minStampSize: Double = 1.0

private let maxTaperTime: TimeInterval = 0.2

private let pressureSensitivity: Double = 1.5

// Testing
private let sizeJitterFrequency: Double = 0.1
private let sizeJitterPersistence: Double = 0.5
private let sizeJitterAmount: Double = 0.4

private let offsetJitterAmount: Double = 0.1

class BrushStrokeStampProcessor {
    
    struct State {
        var stamps: [BrushStrokeEngine.Stamp]
        var segmentIndex: Int
        
        var isFinalized: Bool
    }
    
    private let brush: Brush
    private let scale: Double
    private let ignoreTaper: Bool
    
    private let sizeJitterGenerator: PerlinNoiseGenerator
    private let offsetXJitterGenerator: PerlinNoiseGenerator
    private let offsetYJitterGenerator: PerlinNoiseGenerator
    
    private var lastFinalizedState: State
    
    init(
        brush: Brush,
        scale: Double,
        ignoreTaper: Bool
    ) {
        self.brush = brush
        self.scale = scale
        self.ignoreTaper = ignoreTaper
        
        sizeJitterGenerator = PerlinNoiseGenerator(
            frequency: sizeJitterFrequency,
            octaveCount: 2,
            persistence: sizeJitterPersistence)
        
        offsetXJitterGenerator = PerlinNoiseGenerator(
            frequency: sizeJitterFrequency,
            octaveCount: 2,
            persistence: sizeJitterPersistence)
        
        offsetYJitterGenerator = PerlinNoiseGenerator(
            frequency: sizeJitterFrequency,
            octaveCount: 2,
            persistence: sizeJitterPersistence)
        
        lastFinalizedState = State(
            stamps: [],
            segmentIndex: 0,
            isFinalized: true)
    }
        
    func process(
        samples: [BrushStrokeEngine.Sample]
    ) -> [BrushStrokeEngine.Stamp] {
        // TODO: Simplify this so we're not checking
        // distance so much. Current implementation is
        // too expensive.
        
        guard !samples.isEmpty else { return [] }
        
        let firstSample = samples.first!
        let lastSample = samples.last!
        let endTimeOffset = lastSample.timeOffset
        
        var state = lastFinalizedState
        
        if state.stamps.isEmpty {
            let firstStamp = stamp(
                stampIndex: 0,
                sample: firstSample,
                endTimeOffset: endTimeOffset)
            
            state.stamps.append(firstStamp)
        }
        
        while state.segmentIndex < samples.count - 1 {
            let segmentStartSample = samples[state.segmentIndex]
            let segmentEndSample = samples[state.segmentIndex + 1]
            
            while true {
                let prevStamp = state.stamps.last!
                
                let prevStampToSegmentEnd =
                    segmentEndSample.position - prevStamp.position
                
                let distanceThreshold = max(
                    prevStamp.size * brush.configuration.stampSpacing,
                    minStampDistance)
                
                if prevStampToSegmentEnd.lengthSquared() <
                    distanceThreshold * distanceThreshold
                {
                    break
                }
                
                let stampPosition =
                    prevStamp.position +
                    prevStampToSegmentEnd.normalized() * distanceThreshold
                
                let interpolatedSample = Self.interpolatedSample(
                    position: stampPosition,
                    sample1: segmentStartSample,
                    sample2: segmentEndSample)
                
                let stamp = stamp(
                    stampIndex: state.stamps.count,
                    sample: interpolatedSample,
                    endTimeOffset: endTimeOffset)
                
                state.stamps.append(stamp)
                state.isFinalized = state.isFinalized && stamp.isFinalized
                
                if state.isFinalized {
                    lastFinalizedState = state
                }
            }
            
            state.segmentIndex += 1
        }
        
        return state.stamps
    }
    
    private static func interpolatedSample(
        position: Vector,
        sample1 s1: BrushStrokeEngine.Sample,
        sample2 s2: BrushStrokeEngine.Sample
    ) -> BrushStrokeEngine.Sample {
        
        let d1 = (s1.position - position).length()
        let d2 = (s2.position - position).length()
        let d = max(d1 + d2, 0.001)
        let r = clamp(d2 / d, min: 0, max: 1)
        
        let c1 = r
        let c2 = 1 - r
        
        let timeOffset = c1 * s1.timeOffset + c2 * s2.timeOffset
        let pressure = c1 * s1.pressure + c2 * s2.pressure
        let altitude = c1 * s1.altitude + c2 * s2.altitude
        let azimuth = c1 * s1.azimuth + c2 * s2.azimuth
        
        let isFinalized = s1.isFinalized && s2.isFinalized
        
        return BrushStrokeEngine.Sample(
            timeOffset: timeOffset,
            position: position,
            pressure: pressure,
            altitude: altitude,
            azimuth: azimuth,
            isFinalized: isFinalized)
    }
    
    private func stamp(
        stampIndex: Int,
        sample: BrushStrokeEngine.Sample,
        endTimeOffset: TimeInterval
    ) -> BrushStrokeEngine.Stamp {
        
        let pressure = clamp(
            sample.pressure * pressureSensitivity,
            min: 0, max: 1)
        
        let pressureScale = 1 + brush.configuration.pressureScaling * pressure
        
        let (taperScale, isInTaperEnd) = combinedTaper(
            sampleTimeOffset: sample.timeOffset,
            endTimeOffset: endTimeOffset)
        
        // TODO: Allow brushes to control minimum size more explicitly?
        let scaledBrushSize = map(
            scale,
            in: (0, 1),
            to: (minStampSize, brush.configuration.stampSize))
        
        // TODO: calculate stamp distance properly
        let stampDistance = Double(stampIndex) / scaledBrushSize
        let sizeJitterNoise = sizeJitterGenerator
            .value(at: stampDistance)
        
        let jitterIntensity = clamp(map(pressure, in: (0.5, 1), to: (1, 0.5)), min: 0, max: 1)
        let jitterScale = 1 + sizeJitterAmount * sizeJitterNoise * jitterIntensity
        
        let size = scaledBrushSize
            * pressureScale
            * taperScale
            * jitterScale
        
        let offset = Vector(
            offsetXJitterGenerator.value(at: stampDistance) * offsetJitterAmount * jitterIntensity,
            offsetYJitterGenerator.value(at: stampDistance) * offsetJitterAmount * jitterIntensity)
        
        let clampedSize = max(size, minStampSize)
        
        let rotation = Self.rotation(from: sample.azimuth)
        
        let alpha = brush.configuration.stampAlpha
        
        let isFinalized = sample.isFinalized && !isInTaperEnd
        
        return BrushStrokeEngine.Stamp(
            size: clampedSize,
            offset: offset,
            position: sample.position,
            rotation: rotation,
            alpha: alpha,
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
        sampleTimeOffset: TimeInterval,
        endTimeOffset: TimeInterval
    ) -> (Double, Bool) {
        
        let taperTime: TimeInterval
        
        if ignoreTaper {
            taperTime = 0
        } else {
            taperTime =
                clamp(brush.configuration.taperLength, min: 0, max: 1)
                * maxTaperTime
        }
        
        let normalizedDistanceToStart = sampleTimeOffset / taperTime
        let normalizedDistanceToEnd = (endTimeOffset - sampleTimeOffset) / taperTime
        
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
        
        let c2 = clamp(brush.configuration.taperRoundness, min: 0, max: 1)
        let c1 = 1 - c2
        
        return s1 * c1 + s2 * c2
    }
    
}
