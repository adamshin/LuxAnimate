
import Foundation
import Color
import Render

private let minStampDistance: Double = 1.0

/// Places renderable stamps along the stroke path with appropriate spacing based on brush configuration.

struct StrokeEngineStrokeStampProcessor {
    
    private let brush: Brush
    private let color: Color
    
    private var cursorDistance: Double = 0
    private var lastInputSample: StrokeSample?
    
    private var stampGenerator =
        StrokeEngineStrokeStampGenerator()
    
    // MARK: - Init
    
    init(
        brush: Brush,
        color: Color
    ) {
        self.brush = brush
        self.color = color
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: StrokeSampleBatch
    ) -> StrokeStampBatch {
        
        var output: [StrokeStamp] = []
        
        for sample in input.samples {
            processSample(
                sample: sample,
                output: &output)
        }
        
        return StrokeStampBatch(
            stamps: output,
            isFinalBatch: input.isFinalBatch,
            isFinalized: input.isFinalized)
    }
    
    // MARK: - Internal Logic

    private mutating func processSample(
        sample: StrokeSample,
        output: inout [StrokeStamp]
    ) {
        if let lastInputSample {
            processSampleSegment(
                s0: lastInputSample,
                s1: sample,
                output: &output)
        } else {
            createStampsAtCursor(
                cursorSample: sample,
                output: &output)
        }
        lastInputSample = sample
    }
    
    private mutating func processSampleSegment(
        s0: StrokeSample,
        s1: StrokeSample,
        output: inout [StrokeStamp]
    ) {
        let d0 = s0.strokeDistance
        let d1 = s1.strokeDistance
        
        guard d0 < d1 else { return }
        
        while true {
            guard cursorDistance < d1 else { break }
            
            var t = map(cursorDistance,
                in: (d0, d1),
                to: (0, 1))
            
            t = clamp(t, min: 0, max: 1)
            
            let w0 = 1 - t
            let w1 = t
            
            let cursorSample = try! interpolate(
                v0: s0, v1: s1,
                w0: w0, w1: w1)
            
            createStampsAtCursor(
                cursorSample: cursorSample,
                output: &output)
        }
    }
    
    private mutating func createStampsAtCursor(
        cursorSample: StrokeSample,
        output: inout [StrokeStamp]
    ) {
        stampGenerator.createStampsAtCursor(
            cursorSample: cursorSample,
            brush: brush,
            color: color,
            output: &output)
        
        cursorDistance = Self.nextCursorDistance(
            cursorSample: cursorSample,
            brush: brush)
    }
    
    private static func nextCursorDistance(
        cursorSample: StrokeSample,
        brush: Brush
    ) -> Double {
        
        let size = cursorSample.stampSize
        let spacing = brush.configuration.stampSpacing
        
        let distance = max(
            size * spacing,
            minStampDistance)
        
        return cursorSample.strokeDistance + distance
    }
    
}
