//
//  BrushStrokeInputInterpolationProcessor.swift
//

import Foundation

private let targetSampleRate = 240
private let targetSampleTimeGap = 1 / Double(targetSampleRate)

class BrushStrokeInputInterpolationProcessor {
    
    struct State {
        var outputSamples: [BrushStrokeEngine.Sample]
        var inputSampleIndex: Int
        
        var isFinalized: Bool
    }
    
    private var lastFinalizedState: State
    
    init() {
        lastFinalizedState = State(
            outputSamples: [],
            inputSampleIndex: -3,
            isFinalized: true)
    }
    
    func process(
        samples inputSamples: [BrushStrokeEngine.Sample]
    ) -> [BrushStrokeEngine.Sample] {
        
        guard !inputSamples.isEmpty else { return [] }
        
        var state = lastFinalizedState
        
        let sampleAtIndex: (Int) -> BrushStrokeEngine.Sample = { index in
            if index < 0 {
                return inputSamples[0]
            } else if index >= inputSamples.count - 1 {
                var s = inputSamples[inputSamples.count - 1]
                s.isFinalized = false
                return s
            }
            return inputSamples[index]
        }
        
        let inputSampleIndexEnd = inputSamples.count
        
        while state.inputSampleIndex < inputSampleIndexEnd {
            let s0 = sampleAtIndex(state.inputSampleIndex + 0)
            let s1 = sampleAtIndex(state.inputSampleIndex + 1)
            let s2 = sampleAtIndex(state.inputSampleIndex + 2)
            let s3 = sampleAtIndex(state.inputSampleIndex + 3)
            
            let timeDifference = s2.time - s1.time
            
            let interpolatedSampleCount = max(1,
                Int((timeDifference / targetSampleTimeGap).rounded()))
            
            for index in 0 ..< interpolatedSampleCount {
                let t = Double(index) / Double(interpolatedSampleCount)
                
                let s = Self.interpolatedSample(
                    s0: s0, s1: s1, s2: s2, s3: s3, t: t)
                
                state.outputSamples.append(s)
                state.isFinalized = state.isFinalized && s.isFinalized
            }
            
            state.inputSampleIndex += 1
            
            if state.isFinalized {
                lastFinalizedState = state
            }
        }
        
        return state.outputSamples
    }
    
    private static func interpolatedSample(
        s0: BrushStrokeEngine.Sample,
        s1: BrushStrokeEngine.Sample,
        s2: BrushStrokeEngine.Sample,
        s3: BrushStrokeEngine.Sample,
        t: Double
    ) -> BrushStrokeEngine.Sample {
        
        let (b0, b1, b2, b3) = UniformCubicBSpline.basisValues(t: t)
        
        let basisValues = [b0, b1, b2, b3]
        let samples = [s0, s1, s2, s3]
        
        var o = BrushStrokeEngine.Sample(
            time: 0,
            position: .zero,
            pressure: 0,
            altitude: 0,
            azimuth: .zero,
            isFinalized: true)
        
        for (b, s) in zip(basisValues, samples) {
            o.position += b * s.position
            o.time += b * s.time
            o.pressure += b * s.pressure
            o.altitude += b * s.altitude
            o.azimuth += b * s.azimuth
            
            o.isFinalized = o.isFinalized && s.isFinalized
        }
        return o
    }
    
}
