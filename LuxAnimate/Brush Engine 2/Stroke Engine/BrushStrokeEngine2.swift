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
    private let startTime: TimeInterval
    
    private let inputQueue = BrushStrokeEngineInputQueue()
    private let gapFillProcessor = BrushStrokeEngineGapFillProcessor()
    private let stampProcessor: BrushStrokeEngineStampProcessor
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool,
        startTime: TimeInterval
    ) {
        self.brush = brush
        self.color = color
        self.quickTap = quickTap
        self.startTime = startTime
        
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
        let currentTime = ProcessInfo.processInfo.systemUptime
        let currentTimeOffset = currentTime - startTime
        
        let s1 = inputQueue.process()
        
        let s2 = gapFillProcessor.process(
            input: s1,
            currentTimeOffset: currentTimeOffset)
        
        let stamps = stampProcessor.process(input: s2)
        
        return ProcessOutput(
            brush: brush,
            stamps: stamps)
    }
    
}
