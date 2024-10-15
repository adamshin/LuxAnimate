//
//  BrushStrokeEngine2.swift
//

import Foundation

// MARK: - Structs

extension BrushStrokeEngine2 {
    
    struct ProcessOutput {
        var brush: Brush
        var stamps: [BrushEngine2.Stamp]
    }
    
}

// MARK: - BrushStrokeEngine2

class BrushStrokeEngine2 {
    
    private let brush: Brush
    private let color: Color
    private let quickTap: Bool
    
    private let inputQueue = BrushStrokeEngineInputQueue()
    private let gapFillProcessor = BrushStrokeEngineGapFillProcessor()
    private let stampProcessor: BrushStrokeEngineStampProcessor
    
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
        
        stampProcessor = .init(
            brush: brush,
            scale: scale,
            color: color)
    }
    
    func update(
        addedSamples: [BrushEngine2.InputSample],
        predictedSamples: [BrushEngine2.InputSample]
    ) {
        inputQueue.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func update(
        sampleUpdates: [BrushEngine2.InputSampleUpdate]
    ) {
        inputQueue.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    func process() -> ProcessOutput {
        let s1 = inputQueue.process()
//        let s2 = gapFillProcessor.process(input: s1)
//        let s3 = stampProcessor.process(input: s2)
        
        let stamps = stampProcessor.process(input: s1)
        
        return ProcessOutput(
            brush: brush,
            stamps: stamps)
    }
    
}
