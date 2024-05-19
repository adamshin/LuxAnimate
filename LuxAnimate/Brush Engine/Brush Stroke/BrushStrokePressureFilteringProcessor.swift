//
//  BrushStrokePressureFilteringProcessor.swift
//

import Foundation

private let maxPressureIncrease: Double = 0.05
private let maxPressureDecrease: Double = 0.05 // TODO: Turn this down?

class BrushStrokePressureFilteringProcessor {
    
    struct State {
        var outputSamples: [BrushStrokeEngine.Sample]
        var inputSampleIndex: Int
        
        var isFinalized: Bool
    }
    
    private var lastFinalizedState: State
    
    init() {
        lastFinalizedState = State(
            outputSamples: [],
            inputSampleIndex: 0,
            isFinalized: true)
    }
    
    func process(
        samples inputSamples: [BrushStrokeEngine.Sample]
    ) -> [BrushStrokeEngine.Sample] {
        
        var state = lastFinalizedState
        
        while state.inputSampleIndex < inputSamples.count {
            var sample = inputSamples[state.inputSampleIndex]
            
            let previousSamplePressure: Double
            
            let previousIndex = state.inputSampleIndex - 1
            if previousIndex >= 0 {
                let previousSample = state.outputSamples[previousIndex]
                previousSamplePressure = previousSample.pressure
            } else {
                previousSamplePressure = 0
            }
            
            sample.pressure = clamp(
                sample.pressure,
                min: previousSamplePressure - maxPressureDecrease,
                max: previousSamplePressure + maxPressureIncrease)
            
            state.outputSamples.append(sample)
            state.isFinalized = state.isFinalized && sample.isFinalized
            state.inputSampleIndex += 1
            
            if state.isFinalized {
                lastFinalizedState = state
            }
        }
        
        return state.outputSamples
    }
    
}
