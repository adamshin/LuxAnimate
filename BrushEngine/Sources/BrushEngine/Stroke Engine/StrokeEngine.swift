
import Foundation
import Color

extension StrokeEngine {
    
    struct ProcessorOutput {
        var samples: [Sample]
        var strokeEndTime: TimeInterval
        var isStrokeEnd: Bool
        var isFinalized: Bool
    }
    
    struct StepOutput {
        var stamps: [Stamp]
        var isStrokeEnd: Bool
        var isFinalized: Bool
    }
    
    struct Output {
        var brush: Brush
        var finalizedStamps: [Stamp]
        var nonFinalizedStamps: [Stamp]
    }
    
}

class StrokeEngine {
    
    private let brush: Brush
    
    private var savedState: StrokeEngineState
    
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
            color: color,
            scale: scale,
            smoothing: smoothing,
            applyTaper: !quickTap)
    }
    
    func update(
        addedSamples: [InputSample],
        predictedSamples: [InputSample]
    ) {
        savedState.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func update(
        sampleUpdates: [InputSampleUpdate]
    ) {
        savedState.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    func process() -> Output {
        var state = savedState
        
        var output = Output(
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
