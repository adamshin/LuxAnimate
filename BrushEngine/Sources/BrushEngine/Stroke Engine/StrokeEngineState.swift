
import Foundation
import Color

struct StrokeEngineState {
    
    private var inputQueue:
        StrokeEngineInputQueue
    
    private var smoothingProcessor:
        StrokeEngineSmoothingProcessor
    
    private var stampProcessor:
        StrokeEngineStampProcessor
    
    // MARK: - Init
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        applyTaper: Bool
    ) {
        inputQueue = .init()
        
        smoothingProcessor = .init(
            brush: brush,
            smoothing: smoothing)
        
        stampProcessor = .init(
            brush: brush,
            color: color,
            scale: scale,
            applyTaper: applyTaper)
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
    -> StrokeEngine.StepOutput {
        
        let o1 = inputQueue.processNextSample()
        let o2 = smoothingProcessor.process(input: o1)
        
        return stampProcessor.process(input: o2)
    }
    
}
