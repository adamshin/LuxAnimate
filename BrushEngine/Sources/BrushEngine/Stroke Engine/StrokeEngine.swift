
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

/// StrokeEngine turns touch input into renderable brush strokes through a multi-stage pipeline.
///
/// ## Usage
///
/// StrokeEngine offers two methods for passing in input samples.
///
/// - Use `update(addedSamples:predictedSamples:)` to add new samples.
///
/// - Use `update(sampleUpdates:)` to update predicted sample data.
///
/// The `process()` method should be called each frame. It processes the input queue and returns an incremental stroke to be rendered.
///
/// ## Pipeline
///
/// The engine transforms input samples through five processing stages:
///
/// 1. **Input Queue** - Manages touch input, prediction, and estimated values
/// 2. **Pressure Filtering** - Filters sudden jumps in pressure input
/// 3. **Smoothing** - Applies smoothing using weighted averaging
/// 4. **Stroke Sample** - Generates smooth stroke paths using B-spline interpolation
/// 5. **Stroke Stamp** - Places stamps along the stroke path
///
/// ## Batches
///
/// Batches carry two important flags:
/// - `isFinalBatch`: No more input will arrive (stroke ended)
/// - `isFinalized`: Output is stable and won't change (can be cached)
///
/// A batch can be final but not finalized - this happens when smoothing, prediction, or taper calculations create a "tail" of non-finalized samples at the stroke end.
///
/// ## State Checkpoint
///
/// The engine maintains a `stateCheckpoint` that saves processor state at the last point where all output is finalized. This ensures we only recompute the non-finalized "tail" of the stroke each frame, not the entire stroke.

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
            
            if batch.isFinalBatch {
                break
            }
        }
        
        return stroke
    }
    
}
