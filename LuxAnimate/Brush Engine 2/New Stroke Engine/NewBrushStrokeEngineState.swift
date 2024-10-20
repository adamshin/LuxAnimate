//
//  NewBrushStrokeEngineState.swift
//

import Foundation

extension NewBrushStrokeEngineState {
    
    struct ProcessResult {
        var stamps: [BrushEngine2.Stamp]
    }
    
}

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
    
    mutating func processNextSample()
    -> ProcessResult? {
        
        guard let sample = inputQueue.popNextSample()
        else { return nil }
        
        // TODO: I need to allow processing multiple samples
        // in each processor step. And handle the end of the stroke.
        
        let stamps = stampProcessor.process(
            sample: sample)
        
        return ProcessResult(stamps: stamps)
    }
    
}
