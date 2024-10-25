//
//  BrushStrokeEngineState.swift
//

import Foundation

struct BrushStrokeEngineState {
    
    private var inputQueue: BrushStrokeEngineInputQueue
    private var smoothingProcessor: BrushStrokeEngineSmoothingProcessor
    private var stampProcessor: BrushStrokeEngineStampProcessor
    
    init(
        brush: Brush,
        scale: Double,
        color: Color,
        smoothing: Double,
        applyTaper: Bool
    ) {
        inputQueue = .init()
        
        smoothingProcessor = .init(
            brush: brush,
            smoothing: smoothing)
        
        stampProcessor = .init(
            brush: brush,
            scale: scale,
            color: color,
            applyTaper: applyTaper)
    }
    
    mutating func handleInputUpdate(
        addedSamples: [BrushEngine.InputSample],
        predictedSamples: [BrushEngine.InputSample]
    ) {
        inputQueue.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    mutating func handleInputUpdate(
        sampleUpdates: [BrushEngine.InputSampleUpdate]
    ) {
        inputQueue.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    mutating func processStep()
    -> BrushStrokeEngine.StampProcessorOutput {
        
        let o1 = inputQueue.processNextSample()
        let o2 = smoothingProcessor.process(input: o1)
        
        return stampProcessor.process(input: o2)
    }
    
}
