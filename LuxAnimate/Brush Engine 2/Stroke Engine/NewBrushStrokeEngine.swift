//
//  NewBrushStrokeEngine.swift
//

import Foundation

// MARK: - Structs

extension NewBrushStrokeEngine {
    
    struct ProcessorOutput {
        var samples: [BrushEngine2.Sample]
        var isFinalized: Bool
        var isStrokeEnd: Bool
        var strokeEndTimeOffset: TimeInterval
    }
    
    struct StampProcessorOutput {
        var stamps: [BrushEngine2.Stamp]
        var isFinalized: Bool
        var isStrokeEnd: Bool
    }
    
    struct ProcessOutput {
        var brush: Brush
        var finalizedStamps: [BrushEngine2.Stamp]
        var nonFinalizedStamps: [BrushEngine2.Stamp]
    }
    
}

// MARK: - NewBrushStrokeEngine

class NewBrushStrokeEngine {
    
    private let brush: Brush
    
    private var savedState: NewBrushStrokeEngineState
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool
    ) {
        self.brush = brush
        
        savedState = .init(
            brush: brush,
            scale: scale,
            color: color,
            smoothing: smoothing,
            applyTaper: !quickTap)
    }
    
    func update(
        addedSamples: [BrushEngine2.InputSample],
        predictedSamples: [BrushEngine2.InputSample]
    ) {
        savedState.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func update(
        sampleUpdates: [BrushEngine2.InputSampleUpdate]
    ) {
        savedState.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    func process() -> ProcessOutput {
        var state = savedState
        
        var output = ProcessOutput(
            brush: brush,
            finalizedStamps: [],
            nonFinalizedStamps: [])
        
        while true {
            let stepOutput = state.processStep()
            
            if stepOutput.isFinalized {
                savedState = state
                output.finalizedStamps += stepOutput.stamps
            } else {
                output.nonFinalizedStamps += stepOutput.stamps
            }
            
            if stepOutput.isStrokeEnd {
                break
            }
        }
        
        return output
    }
    
}
