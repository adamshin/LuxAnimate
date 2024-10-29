
import Foundation
import Geometry
import Color

private let segmentSubdivisionCount = 10

// MARK: - Structs

extension StrokeEngineStrokeSampleProcessor {
    
    struct Config {
        let strokeSampleGenerator: StrokeSampleGenerator
    }
    
    struct State {
        var lastControlPointSamples: [Sample]?
        var lastStrokeSample: StrokeSample?
        var isOutputFinalized = true
    }
    
}

// MARK: - StrokeEngineStrokeSampleProcessor

struct StrokeEngineStrokeSampleProcessor {
    
    private let config: Config
    private var state = State()
    
    // MARK: - Init
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        applyTaper: Bool
    ) {
        let strokeSampleGenerator = StrokeSampleGenerator(
            brush: brush,
            scale: scale,
            applyTaper: applyTaper)
        
        config = Config(
            strokeSampleGenerator: strokeSampleGenerator)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: StrokeEngine.ProcessorOutput
    ) -> StrokeEngine.StrokeSampleProcessorOutput {
        
        if !input.isFinalized {
            state.isOutputFinalized = false
        }
        
        var output: [StrokeSample] = []
        
        for sample in input.samples {
            Self.processSample(
                sample: sample,
                strokeEndTime: input.strokeEndTime,
                config: config,
                state: &state,
                output: &output)
        }
        
        if input.isStrokeEnd,
            let lastControlPointSample =
                state.lastControlPointSamples?.last
        {
            state.isOutputFinalized = false
            
            for _ in 0 ..< 3 {
                Self.processSample(
                    sample: lastControlPointSample,
                    strokeEndTime: input.strokeEndTime,
                    config: config,
                    state: &state,
                    output: &output)
            }
        }
        
        return .init(
            strokeSamples: output,
            isStrokeEnd: input.isStrokeEnd,
            isFinalized: state.isOutputFinalized)
    }
    
    // MARK: - Internal Logic
    
    private static func processSample(
        sample: Sample,
        strokeEndTime: TimeInterval,
        config: Config,
        state: inout State,
        output: inout [StrokeSample]
    ) {
        if let lastControlPointSamples =
            state.lastControlPointSamples
        {
            var controlPointSamples =
                lastControlPointSamples
            
            controlPointSamples.removeFirst()
            controlPointSamples.append(sample)
            
            processSegment(
                controlPointSamples: controlPointSamples,
                strokeEndTime: strokeEndTime,
                config: config,
                state: &state,
                output: &output)
            
        } else {
            let controlPointSamples = Array(
                repeating: sample,
                count: 4)
            
            processSegment(
                controlPointSamples: controlPointSamples,
                strokeEndTime: strokeEndTime,
                config: config,
                state: &state,
                output: &output)
        }
    }
    
    private static func processSegment(
        controlPointSamples: [Sample],
        strokeEndTime: TimeInterval,
        config: Config,
        state: inout State,
        output: inout [StrokeSample]
    ) {
        state.lastControlPointSamples = controlPointSamples
        
        let subSegmentSamples = subSegmentSamples(
            controlPointSamples: controlPointSamples,
            subdivisionCount: segmentSubdivisionCount)
        
        for sample in subSegmentSamples {
            processSubSegmentSample(
                sample: sample,
                strokeEndTime: strokeEndTime,
                config: config,
                state: &state,
                output: &output)
        }
    }
    
    private static func processSubSegmentSample(
        sample: Sample,
        strokeEndTime: TimeInterval,
        config: Config,
        state: inout State,
        output: inout [StrokeSample]
    ) {
        let strokeDistance: Double
        
        if let lastStrokeSample = state.lastStrokeSample {
            let positionDelta =
                sample.position -
                lastStrokeSample.position
            
            let distanceFromLastStrokeSample =
                positionDelta.length()
            
            strokeDistance =
                lastStrokeSample.strokeDistance +
                distanceFromLastStrokeSample
            
        } else {
            strokeDistance = 0
        }
        
        let strokeSampleOutput = config
            .strokeSampleGenerator
            .strokeSample(
                sample: sample,
                strokeDistance: strokeDistance,
                strokeEndTime: strokeEndTime)
        
        let strokeSample = strokeSampleOutput.strokeSample
        
        output.append(strokeSample)
        state.lastStrokeSample = strokeSample
        
        if strokeSampleOutput.isNonFinalized {
            state.isOutputFinalized = false
        }
    }
    
    private static func subSegmentSamples(
        controlPointSamples: [Sample],
        subdivisionCount: Int
    ) -> [Sample] {
        
        guard controlPointSamples.count == 4 else {
            fatalError()
        }
        
        let count = segmentSubdivisionCount
        
        var output: [Sample] = []
        output.reserveCapacity(count)
        
        for i in 0 ..< count {
            let t = Double(i) / Double(count)
            
            let (b0, b1, b2, b3) =
                UniformCubicBSpline.basisValues(t: t)
            
            let sample = try! interpolate(
                (controlPointSamples[0], b0),
                (controlPointSamples[1], b1),
                (controlPointSamples[2], b2),
                (controlPointSamples[3], b3))
            
            output.append(sample)
        }
        return output
    }
    
}
