
import Foundation
import Color
import Render

extension StrokeEngine {
    
    struct IncrementalStroke {
        var brush: Brush
        var finalizedStamps: [StrokeStamp]
        var nonFinalizedStamps: [StrokeStamp]
    }
    
}

class StrokeEngine {
    
    private let brush: Brush
    
    private var stateCheckpoint: StrokeEngineState
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool
    ) {
        self.brush = brush
        
        stateCheckpoint = .init(
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
        stateCheckpoint.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func update(
        sampleUpdates: [InputSampleUpdate]
    ) {
        stateCheckpoint.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    func process() -> IncrementalStroke {
        var state = stateCheckpoint
        
        var output = IncrementalStroke(
            brush: brush,
            finalizedStamps: [],
            nonFinalizedStamps: [])
        
        while true {
            let stepOutput = state.processStep()
            
            if stepOutput.isFinalized {
                stateCheckpoint = state
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
