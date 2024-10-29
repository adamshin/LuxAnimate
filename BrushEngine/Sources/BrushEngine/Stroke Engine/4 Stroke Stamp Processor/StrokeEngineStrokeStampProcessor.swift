
import Foundation
import Color
import Render

private let minStampDistance: Double = 1.0

struct StrokeEngineStrokeStampProcessor {
    
    struct Config {
        let brush: Brush
        let color: Color
    }
    
    struct State {
        var nextCursorStrokeDistance: Double = 0
        var lastSample: StrokeSample?
    }
    
    private let config: Config
    private var state = State()
    
    // MARK: - Init
    
    init(
        brush: Brush,
        color: Color
    ) {
        config = Config(
            brush: brush,
            color: color)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: StrokeEngine.StrokeSampleProcessorOutput
    ) -> StrokeEngine.StrokeStampProcessorOutput {
        
        var output: [SpriteRenderer.Sprite] = []
        
        for sample in input.strokeSamples {
            Self.processStrokeSample(
                sample: sample,
                config: config,
                state: &state,
                output: &output)
        }
        
        return .init(
            stampSprites: output,
            isStrokeEnd: input.isStrokeEnd,
            isFinalized: input.isFinalized)
    }
    
    // MARK: - Internal Methods
    
    private static func processStrokeSample(
        sample: StrokeSample,
        config: Config,
        state: inout State,
        output: inout [SpriteRenderer.Sprite]
    ) {
        if let lastSample = state.lastSample {
            processStrokeSegment(
                startSample: lastSample,
                endSample: sample,
                config: config,
                state: &state,
                output: &output)
        } else {
            processFirstStrokeSample(
                sample: sample,
                config: config,
                state: &state,
                output: &output)
        }
        
        state.lastSample = sample
    }
    
    private static func processStrokeSegment(
        startSample: StrokeSample,
        endSample: StrokeSample,
        config: Config,
        state: inout State,
        output: inout [SpriteRenderer.Sprite]
    ) {
        let startStrokeDist = startSample.strokeDistance
        let endStrokeDist = endSample.strokeDistance
        
        guard startStrokeDist < endStrokeDist
        else { return }
        
        while true {
            guard state.nextCursorStrokeDistance
                < endStrokeDist
            else { break }
            
            let t0 = map(
                state.nextCursorStrokeDistance,
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
                config: config,
                state: &state,
                output: &output)
        }
    }
    
    private static func processFirstStrokeSample(
        sample: StrokeSample,
        config: Config,
        state: inout State,
        output: inout [SpriteRenderer.Sprite]
    ) {
        createStamps(
            cursorSample: sample,
            config: config,
            state: &state,
            output: &output)
    }
    
    private static func createStamps(
        cursorSample: StrokeSample,
        config: Config,
        state: inout State,
        output: inout [SpriteRenderer.Sprite]
    ) {
        StrokeStampGenerator.generate(
            sample: cursorSample,
            color: config.color,
            output: &output)
        
        state.nextCursorStrokeDistance =
            nextCursorStrokeDistance(
                cursorSample: cursorSample,
                config: config)
    }
    
    private static func nextCursorStrokeDistance(
        cursorSample: StrokeSample,
        config: Config
    ) -> Double {
        let stampSize = cursorSample.stampSize
        let stampSpacing = config
            .brush.configuration.stampSpacing
        
        let distance = max(
            stampSize * stampSpacing,
            minStampDistance)
        
        return cursorSample.strokeDistance + distance
    }
    
}
