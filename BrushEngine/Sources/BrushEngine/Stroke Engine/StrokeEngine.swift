
import Foundation
import Color
import Render

extension StrokeEngine {
    
    struct ProcessorOutput {
        var samples: [Sample]
        var strokeEndTime: TimeInterval
        var isStrokeEnd: Bool
        var isFinalized: Bool
    }
    
    struct StrokeSampleProcessorOutput {
        var strokeSamples: [StrokeSample]
        var isStrokeEnd: Bool
        var isFinalized: Bool
    }
    
    struct StrokeStampProcessorOutput {
        var stampSprites: [SpriteRenderer.Sprite]
        var isStrokeEnd: Bool
        var isFinalized: Bool
    }
    
    struct Output {
        var brush: Brush
        var finalizedStampSprites: [SpriteRenderer.Sprite]
        var nonFinalizedStampSprites: [SpriteRenderer.Sprite]
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
            finalizedStampSprites: [],
            nonFinalizedStampSprites: [])
        
        while true {
            let stepOutput = state.processStep()
            
            if stepOutput.isFinalized {
                savedState = state
                output.finalizedStampSprites
                    += stepOutput.stampSprites
            } else {
                output.nonFinalizedStampSprites
                    += stepOutput.stampSprites
            }
            
            if stepOutput.isStrokeEnd {
                break
            }
        }
        
        return output
    }
    
}
