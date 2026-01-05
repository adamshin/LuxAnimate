
import Foundation
import Color
import Render

struct StrokeEngineState {
    
    private var inputQueue:
        StrokeEngineInputQueue
    
    private var pressureFilteringProcessor:
        StrokeEnginePressureFilteringProcessor
    
    private var smoothingProcessor:
        StrokeEngineSmoothingProcessor
    
    private var strokeSampleProcessor:
        StrokeEngineStrokeSampleProcessor
    
    private var strokeStampProcessor:
        StrokeEngineStrokeStampProcessor
    
    // MARK: - Init
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        applyTaper: Bool
    ) {
        inputQueue = .init()
        
        pressureFilteringProcessor = .init()
        
        smoothingProcessor = .init(
            brush: brush,
            smoothing: smoothing)
        
        strokeSampleProcessor = .init(
            brush: brush,
            color: color,
            scale: scale,
            applyTaper: applyTaper)
        
        strokeStampProcessor = .init(
            brush: brush,
            color: color)
    }
    
    // MARK: - Interface
    
    mutating func handleInputUpdate(
        addedSamples: [InputSample],
        predictedSamples: [InputSample]
    ) {
        inputQueue.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    mutating func handleInputUpdate(
        sampleUpdates: [InputSampleUpdate]
    ) {
        inputQueue.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    mutating func processStep()
    -> StrokeStampBatch {
        
        let o1 = inputQueue.processNextSample()
        let o2 = pressureFilteringProcessor.process(input: o1)
        let o3 = smoothingProcessor.process(input: o2)
        let o4 = strokeSampleProcessor.process(input: o3)
        let o5 = strokeStampProcessor.process(input: o4)
        
        return o5
    }
    
}
