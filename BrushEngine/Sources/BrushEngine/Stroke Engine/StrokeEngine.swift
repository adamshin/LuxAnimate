
import Foundation
import Color
import Render

// MARK: - Types

extension StrokeEngine {
    
    struct IncrementalStroke {
        var brush: Brush
        var finalizedStamps: [StrokeStamp]
        var nonFinalizedStamps: [StrokeStamp]
    }
    
}

// MARK: - StrokeEngine

class StrokeEngine {
    
    private let brush: Brush
    
    private var stateCheckpoint: StrokeEngineState
    
    // MARK: - Init
    
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
    
    // MARK: - Interface
    
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
        
        var stroke = IncrementalStroke(
            brush: brush,
            finalizedStamps: [],
            nonFinalizedStamps: [])
        
        while true {
            let batch = state.processStep()
            
            if batch.isFinalized {
                stateCheckpoint = state
                stroke.finalizedStamps += batch.stamps
            } else {
                stroke.nonFinalizedStamps += batch.stamps
            }
            
            if batch.isStrokeEnd {
                break
            }
        }
        
        return stroke
    }
    
}
