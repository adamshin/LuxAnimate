//
//  NewBrushStrokeEngineState.swift
//

import Foundation

struct NewBrushStrokeEngineState {
    
    var inputQueue: NewBrushStrokeEngineInputQueue
    var stampProcessor: NewBrushStrokeEngineStampProcessor
    
    init(
        brush: Brush,
        scale: Double,
        color: Color
    ) {
        inputQueue = .init()
        
        stampProcessor = .init(
            brush: brush,
            scale: scale,
            color: color)
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
        
        return stampProcessor.process(input: o1)
    }
    
}
