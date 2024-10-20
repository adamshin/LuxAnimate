//
//  NewBrushStrokeEngine.swift
//

import Foundation

// MARK: - Structs

extension NewBrushStrokeEngine {
    
    struct ProcessResult {
        var brush: Brush
        var stamps: [BrushEngine2.Stamp]
    }
    
}

// MARK: - NewBrushStrokeEngine

class NewBrushStrokeEngine {
    
    private let brush: Brush
    private let color: Color
    private let quickTap: Bool
    
    private var savedState: NewBrushStrokeEngineState
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool
    ) {
        self.brush = brush
        self.color = color
        self.quickTap = quickTap
        
        savedState = .init(
            brush: brush,
            scale: scale,
            color: color)
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
    
    func process() -> ProcessResult {
        var state = savedState
        var stamps: [BrushEngine2.Stamp] = []
        
        while let processResult = state.processNextSample() {
            stamps += processResult.stamps
            
            let isResultFinalized = processResult.stamps
                .allSatisfy { $0.isFinalized }
            
            if isResultFinalized {
                savedState = state
            }
        }
        
        return ProcessResult(
            brush: brush,
            stamps: stamps)
    }
    
}
