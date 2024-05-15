//
//  BrushStrokeSmoothingProcessor.swift
//

import Foundation

private let minSmoothingWindowSize = 1
private let maxSmoothingWindowSize = 100

class BrushStrokeSmoothingProcessor {
    
    struct State {
        var samples: [BrushStrokeEngine.Sample]
        var windowIndex: Int
        
        var isFinalized: Bool
    }
    
    private let windowSize: Int
    private let windowWeights: [Double]
    
    private var lastFinalizedState: State
    
    init(smoothing: Double) {
        let windowSize = clamp(
            Int(smoothing * Double(maxSmoothingWindowSize)),
            min: minSmoothingWindowSize,
            max: maxSmoothingWindowSize)
        
        self.windowSize = windowSize
        
        windowWeights = (0 ..< windowSize).map {
            Self.windowWeightParabola(index: $0, windowSize: windowSize)
        }
        
        lastFinalizedState = State(
            samples: [],
            windowIndex: 1 - windowSize,
            isFinalized: true)
    }
    
    func process(
        samples: [BrushStrokeEngine.Sample]
    ) -> [BrushStrokeEngine.Sample] {
        
        guard !samples.isEmpty else {
            return []
        }
        
        var state = lastFinalizedState
        let windowRangeEnd = samples.count
        
        while state.windowIndex < windowRangeEnd {
            let sample = Self.weightedAverage(
                samples: samples,
                windowRangeStart: state.windowIndex,
                windowWeights: windowWeights)
            
            state.samples.append(sample)
            state.windowIndex += 1
            state.isFinalized = state.isFinalized && sample.isFinalized
            
            if state.isFinalized {
                lastFinalizedState = state
            }
        }
        
        return state.samples
    }
    
    private static func weightedAverage(
        samples: [BrushStrokeEngine.Sample],
        windowRangeStart: Int,
        windowWeights: [Double]
    ) -> BrushStrokeEngine.Sample {
        
        let windowSize = windowWeights.count
        
        let isWindowPastEnd = 
            windowRangeStart + windowSize > samples.count
        
        var position = Vector.zero
        var timeOffset: TimeInterval = 0
        var pressure: Double = 0
        var altitude: Double = 0
        var azimuth: Vector = .zero
        var totalWeight: Double = 0
        
        var allFinalized = true
        
        for index in 0 ..< windowSize {
            let weight = windowWeights[index]
            
            let sampleIndex = windowRangeStart + index
            
            let clampedSampleIndex = clamp(
                sampleIndex,
                min: 0,
                max: samples.count - 1)
            
            let s = samples[clampedSampleIndex]
            
            position += s.position * weight
            timeOffset += s.timeOffset * weight
            pressure += s.pressure * weight
            altitude += s.altitude * weight
            azimuth += s.azimuth * weight
            totalWeight += weight
            
            allFinalized = allFinalized && s.isFinalized
        }
        timeOffset /= totalWeight
        position /= totalWeight
        pressure /= totalWeight
        altitude /= totalWeight
        azimuth /= totalWeight
        
        let isFinalized = allFinalized && !isWindowPastEnd
        
        return BrushStrokeEngine.Sample(
            timeOffset: timeOffset,
            position: position,
            pressure: pressure,
            altitude: altitude,
            azimuth: azimuth,
            isFinalized: isFinalized)
    }
    
    private static func windowWeightFlat(
        index: Int, windowSize: Int
    ) -> Double {
        return 1
    }
    
    private static func windowWeightTrapezoid(
        index: Int, windowSize: Int
    ) -> Double {
        let windowEaseAmount = 0.25
        
        let easeSampleCount = Int(Double(windowSize) * windowEaseAmount)
        
        let distToStart = index
        let distToEnd = windowSize - index - 1
        
        if distToStart < easeSampleCount {
            return Double(distToStart) / Double(easeSampleCount)
        }
        if distToEnd < easeSampleCount {
            return Double(distToEnd) / Double(easeSampleCount)
        }
        return 1
    }
    
    private static func windowWeightParabola(
        index: Int, windowSize: Int
    ) -> Double {
        if windowSize <= 3 { return 1 }
        
        let p = Double(index) / Double(windowSize - 1)
        let x = (p * 2) - 1
        return 1 - (x * x)
    }
    
}
