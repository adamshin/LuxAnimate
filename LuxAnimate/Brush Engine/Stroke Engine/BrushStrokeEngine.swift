//
//  BrushStrokeEngine.swift
//

import Foundation

// MARK: - Structs

extension BrushStrokeEngine {
    
    struct ProcessorOutput {
        var samples: [BrushEngine.Sample]
        var isFinalized: Bool
        var isStrokeEnd: Bool
        var strokeEndTime: TimeInterval
    }
    
    struct StampProcessorOutput {
        var stamps: [BrushEngine.Stamp]
        var isFinalized: Bool
        var isStrokeEnd: Bool
    }
    
    struct ProcessOutput {
        var brush: Brush
        var finalizedStamps: [BrushEngine.Stamp]
        var nonFinalizedStamps: [BrushEngine.Stamp]
    }
    
}

// MARK: - BrushStrokeEngine

class BrushStrokeEngine {
    
    private let brush: Brush
    
    private var savedState: BrushStrokeEngineState
    
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
        addedSamples: [BrushEngine.InputSample],
        predictedSamples: [BrushEngine.InputSample]
    ) {
        savedState.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func update(
        sampleUpdates: [BrushEngine.InputSampleUpdate]
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
