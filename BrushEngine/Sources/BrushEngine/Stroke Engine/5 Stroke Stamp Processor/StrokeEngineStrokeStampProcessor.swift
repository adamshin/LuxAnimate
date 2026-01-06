
import Foundation
import Color
import Render

private let minStampDistance: Double = 1.0

struct StrokeEngineStrokeStampProcessor {
    
    private let brush: Brush
    private let color: Color
    
    private var nextCursorStrokeDistance: Double = 0
    private var lastInputSample: StrokeSample?
    private var stampGenerator = StrokeEngineStrokeStampGenerator()
    
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
    
    // MARK: - Internal Methods

    private mutating func processSample(
        sample: StrokeSample,
        output: inout [StrokeStamp]
    ) {
        if let lastInputSample {
            processStrokeSegment(
                startSample: lastInputSample,
                endSample: sample,
                output: &output)
        } else {
            processFirstStrokeSample(
                sample: sample,
                output: &output)
        }
        
        lastInputSample = sample
    }
    
    private mutating func processStrokeSegment(
        startSample: StrokeSample,
        endSample: StrokeSample,
        output: inout [StrokeStamp]
    ) {
        let startStrokeDist = startSample.strokeDistance
        let endStrokeDist = endSample.strokeDistance
        
        guard startStrokeDist < endStrokeDist
        else { return }
        
        while true {
            guard nextCursorStrokeDistance < endStrokeDist
            else { break }
            
            let t0 = map(
                nextCursorStrokeDistance,
                in: (startStrokeDist, endStrokeDist),
                to: (0, 1))
            let t = clamp(t0, min: 0, max: 1)
            
            let s0 = startSample
            let s1 = endSample
            
            let cursorSample = try! interpolate(
                v0: s0, v1: s1,
                w0: 1 - t, w1: t)
            
            createStamps(
                cursorSample: cursorSample,
                output: &output)
        }
    }
    
    private mutating func processFirstStrokeSample(
        sample: StrokeSample,
        output: inout [StrokeStamp]
    ) {
        createStamps(
            cursorSample: sample,
            output: &output)
    }
    
    private mutating func createStamps(
        cursorSample: StrokeSample,
        output: inout [StrokeStamp]
    ) {
        stampGenerator.generate(
            sample: cursorSample,
            brush: brush,
            color: color,
            output: &output)
        
        nextCursorStrokeDistance =
            Self.nextCursorStrokeDistance(
                cursorSample: cursorSample,
                brush: brush)
    }
    
    private static func nextCursorStrokeDistance(
        cursorSample: StrokeSample,
        brush: Brush
    ) -> Double {
        
        let stampSize = cursorSample.stampSize
        let stampSpacing = brush.configuration.stampSpacing
        
        let distance = max(
            stampSize * stampSpacing,
            minStampDistance)
        
        return cursorSample.strokeDistance + distance
    }
    
}
