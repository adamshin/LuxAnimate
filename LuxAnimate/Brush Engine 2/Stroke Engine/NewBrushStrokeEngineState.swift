//
//  NewBrushStrokeEngineState.swift
//

import Foundation

struct NewBrushStrokeEngineState {
    
    var inputQueue: NewBrushStrokeEngineInputQueue
    var smoothingProcessor: NewBrushStrokeEngineSmoothingProcessor
    var stampProcessor: NewBrushStrokeEngineStampProcessor
    
    init(
        brush: Brush,
        scale: Double,
        color: Color,
        smoothing: Double,
        applyTaper: Bool
    ) {
        inputQueue = .init()
        
        smoothingProcessor = .init(
            smoothing: smoothing)
        
        stampProcessor = .init(
            brush: brush,
            scale: scale,
            color: color,
            applyTaper: applyTaper)
    }
    
    mutating func handleInputUpdate(
        addedSamples: [BrushEngine2.InputSample],
        predictedSamples: [BrushEngine2.InputSample]
    ) {
        inputQueue.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    mutating func handleInputUpdate(
        sampleUpdates: [BrushEngine2.InputSampleUpdate]
    ) {
        inputQueue.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    mutating func processStep()
    -> NewBrushStrokeEngine.StampProcessorOutput {
        
        let o1 = inputQueue.processNextSample()
        let o2 = smoothingProcessor.process(input: o1)
        
        return stampProcessor.process(input: o2)
    }
    
}
