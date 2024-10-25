//
//  BrushStrokeEngineStampProcessor.swift
//

import Foundation

private let segmentSubdivisionCount = 10

private let wobbleOctaveCount = 2
private let wobblePersistence: Double = 0.5

private let drawControlPoints = false

// MARK: - Structs

extension BrushStrokeEngineStampProcessor {
    
    struct Config {
        var stampGenerator: BrushStrokeEngineStampGenerator
        
        let sizeWobbleGenerator: PerlinNoiseGenerator
        let offsetXWobbleGenerator: PerlinNoiseGenerator
        let offsetYWobbleGenerator: PerlinNoiseGenerator
    }
    
    struct State {
        var lastSegment: Segment?
        
        var lastStampData = LastStampData(
            strokeDistance: 0,
            distanceToNextStamp: 0)
        
        var isOutputFinalized = true
    }
    
    struct LastStampData {
        var strokeDistance: Double
        var distanceToNextStamp: Double
    }
    
    struct Segment {
        var controlPointSamples: [BrushEngine.Sample]
        var subSegments: [SubSegment]
        var startStrokeDistance: Double
        var length: Double
    }
    
    struct SubSegment {
        var start: SubSegmentEndpoint
        var end: SubSegmentEndpoint
        var startStrokeDistance: Double
        var length: Double
    }
    
    struct SubSegmentEndpoint {
        var sample: BrushEngine.Sample
        var noiseSample: BrushEngine.NoiseSample
    }
    
}

// MARK: - BrushStrokeEngineStampProcessor

struct BrushStrokeEngineStampProcessor {
    
    private let config: Config
    private var state = State()
    
    // MARK: - Init
    
    init(
        brush: Brush,
        scale: Double,
        color: Color,
        applyTaper: Bool
    ) {
        let stampGenerator =
            BrushStrokeEngineStampGenerator(
                brush: brush,
                scale: scale,
                color: color,
                applyTaper: applyTaper)
        
        let sizeWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.config.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
        
        let offsetXWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.config.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
        
        let offsetYWobbleGenerator = PerlinNoiseGenerator(
            frequency: brush.config.wobbleFrequency,
            octaveCount: wobbleOctaveCount,
            persistence: wobblePersistence)
        
        config = Config(
            stampGenerator: stampGenerator,
            sizeWobbleGenerator: sizeWobbleGenerator,
            offsetXWobbleGenerator: offsetXWobbleGenerator,
            offsetYWobbleGenerator: offsetYWobbleGenerator)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: BrushStrokeEngine.ProcessorOutput
    ) -> BrushStrokeEngine.StampProcessorOutput {
        
        if !input.isFinalized {
            state.isOutputFinalized = false
        }
        
        var outputStamps: [BrushEngine.Stamp] = []
        
        for sample in input.samples {
            Self.processSample(
                config: config,
                sample: sample,
                strokeEndTime: input.strokeEndTime,
                state: &state,
                outputStamps: &outputStamps)
        }
        
        if input.isStrokeEnd,
            let lastSample = state.lastSegment?
                .controlPointSamples.last
        {
            state.isOutputFinalized = false
            
            for _ in 0 ..< 2 {
                Self.processSample(
                    config: config,
                    sample: lastSample,
                    strokeEndTime: input.strokeEndTime,
                    state: &state,
                    outputStamps: &outputStamps)
            }
        }
        
        return BrushStrokeEngine.StampProcessorOutput(
            stamps: outputStamps,
            isFinalized: state.isOutputFinalized,
            isStrokeEnd: input.isStrokeEnd)
    }
    
    // MARK: - Internal Logic
    
    private static func processSample(
        config: Config,
        sample: BrushEngine.Sample,
        strokeEndTime: TimeInterval,
        state: inout State,
        outputStamps: inout [BrushEngine.Stamp]
    ) {
        let segment: Segment
        if let lastSegment = state.lastSegment {
            var controlPointSamples =
                lastSegment.controlPointSamples
            
            controlPointSamples.removeFirst()
            controlPointSamples.append(sample)
            
            let startStrokeDistance =
                lastSegment.startStrokeDistance +
                lastSegment.length
            
            segment = createSegment(
                config: config,
                controlPointSamples: controlPointSamples,
                startStrokeDistance: startStrokeDistance)
            
        } else {
            let controlPointSamples = Array(
                repeating: sample,
                count: 4)
            
            segment = createSegment(
                config: config,
                controlPointSamples: controlPointSamples,
                startStrokeDistance: 0)
        }
            
        state.lastSegment = segment
        
        processSegment(
            config: config,
            segment: segment,
            strokeEndTime: strokeEndTime,
            state: &state,
            outputStamps: &outputStamps)
    }
    
    private static func processSegment(
        config: Config,
        segment: Segment,
        strokeEndTime: TimeInterval,
        state: inout State,
        outputStamps: inout [BrushEngine.Stamp]
    ) {
        if drawControlPoints {
            for s in segment.controlPointSamples {
                let stamp = BrushEngine.Stamp(
                    position: s.position,
                    size: 20,
                    rotation: 0,
                    alpha: 1,
                    color: .debugRed,
                    offset: .zero)
                outputStamps.append(stamp)
            }
        }
        
        for subSegment in segment.subSegments {
            processSubSegment(
                config: config,
                subSegment: subSegment,
                strokeEndTime: strokeEndTime,
                state: &state,
                outputStamps: &outputStamps)
        }
    }
    
    private static func processSubSegment(
        config: Config,
        subSegment: SubSegment,
        strokeEndTime: TimeInterval,
        state: inout State,
        outputStamps: inout [BrushEngine.Stamp]
    ) {
        while true {
            let nextStampStrokeDistance =
                state.lastStampData.strokeDistance +
                state.lastStampData.distanceToNextStamp
            
            let nextStampSubSegmentDistance =
                nextStampStrokeDistance -
                subSegment.startStrokeDistance
            
            if nextStampSubSegmentDistance
                > subSegment.length + 0.001
            { break }
            
            let t: Double
            if subSegment.length != 0 {
                let t0 = nextStampSubSegmentDistance /
                    subSegment.length
                t = clamp(t0, min: 0, max: 1)
            } else {
                t = 0
            }
            
            let s1 = subSegment.start.sample
            let s2 = subSegment.end.sample
            
            let ns1 = subSegment.start.noiseSample
            let ns2 = subSegment.end.noiseSample
            
            let sample = try! BrushEngineSampleInterpolator
                .interpolate(
                    samples: [s1, s2],
                    weights: [1-t, t])
            
            let noiseSample = try! BrushEngineSampleInterpolator
                .interpolate(
                    noiseSamples: [ns1, ns2],
                    weights: [1-t, t])
            
            let stampOutput =
                config.stampGenerator.stamp(
                    sample: sample,
                    noiseSample: noiseSample,
                    strokeEndTime: strokeEndTime)
            
            let stamp = stampOutput.stamp
            outputStamps.append(stamp)
            
            if stampOutput.isNonFinalized {
                state.isOutputFinalized = false
            }
            
            let distanceToNextStamp =
                max(1.0, stampOutput.distanceToNextStamp)
            
            state.lastStampData = LastStampData(
                strokeDistance: nextStampStrokeDistance,
                distanceToNextStamp: distanceToNextStamp)
        }
    }
    
    // MARK: - Segment
    
    private static func createSegment(
        config: Config,
        controlPointSamples: [BrushEngine.Sample],
        startStrokeDistance: Double
    ) -> Segment {
        
        let subSegments = subSegments(
            config: config,
            controlPointSamples: controlPointSamples,
            segmentStartStrokeDistance: startStrokeDistance)
        
        let length = subSegments
            .reduce(0, { $0 + $1.length })
        
        return Segment(
            controlPointSamples: controlPointSamples,
            subSegments: subSegments,
            startStrokeDistance: startStrokeDistance,
            length: length)
    }
    
    private static func subSegments(
        config: Config,
        controlPointSamples: [BrushEngine.Sample],
        segmentStartStrokeDistance: Double
    ) -> [SubSegment] {
        
        let subSegmentSamples = subSegmentSamples(
            controlPointSamples: controlPointSamples)
        
        let subSegmentCount = subSegmentSamples.count - 1
        guard subSegmentCount > 0 else {
            fatalError()
        }
        
        var output: [SubSegment] = []
        output.reserveCapacity(subSegmentCount)
        
        var startStrokeDistance = segmentStartStrokeDistance
        
        for i in 0 ..< subSegmentCount {
            let startSample = subSegmentSamples[i]
            let endSample = subSegmentSamples[i + 1]
            
            let positionDifference =
                endSample.position -
                startSample.position
            
            let length = positionDifference.length()
            
            let endStrokeDistance =
                startStrokeDistance + length
            
            let start: SubSegmentEndpoint
            if let lastSubSegment = output.last {
                start = lastSubSegment.end
            } else {
                let startNoiseSample = noiseSample(
                    config: config,
                    strokeDistance: startStrokeDistance)
                
                start = SubSegmentEndpoint(
                    sample: startSample,
                    noiseSample: startNoiseSample)
            }
            
            let endNoiseSample = noiseSample(
                config: config,
                strokeDistance: endStrokeDistance)
            
            let end = SubSegmentEndpoint(
                sample: endSample,
                noiseSample: endNoiseSample)
            
            let subSegment = SubSegment(
                start: start,
                end: end,
                startStrokeDistance: startStrokeDistance,
                length: length)
            
            output.append(subSegment)
            startStrokeDistance += length
        }
        return output
    }
    
    private static func subSegmentSamples(
        controlPointSamples: [BrushEngine.Sample]
    ) -> [BrushEngine.Sample] {
        
        guard controlPointSamples.count == 4 else {
            fatalError()
        }
        let s0 = controlPointSamples[0]
        let s1 = controlPointSamples[1]
        let s2 = controlPointSamples[2]
        let s3 = controlPointSamples[3]
        
        let count = segmentSubdivisionCount
        
        var output: [BrushEngine.Sample] = []
        output.reserveCapacity(count)
        
        for i in 0 ... count {
            let t = Double(i) / Double(count)
            
            let (b0, b1, b2, b3) = UniformCubicBSpline
                .basisValues(t: t)
            
            let sample = try! BrushEngineSampleInterpolator
                .interpolate(
                    samples: [s0, s1, s2, s3],
                    weights: [b0, b1, b2, b3])
            
            output.append(sample)
        }
        return output
    }
    
    // MARK: - Noise Sample
    
    private static func noiseSample(
        config: Config,
        strokeDistance: Double
    ) -> BrushEngine.NoiseSample {
        
        let wobbleDistance = strokeDistance
            / config.stampGenerator.baseStampSize
        
        let sizeWobble = config.sizeWobbleGenerator
            .value(at: wobbleDistance)
        let offsetXWobble = config.offsetXWobbleGenerator
            .value(at: wobbleDistance)
        let offsetYWobble = config.offsetYWobbleGenerator
            .value(at: wobbleDistance)
        
        return BrushEngine.NoiseSample(
            sizeWobble: sizeWobble,
            offsetXWobble: offsetXWobble,
            offsetYWobble: offsetYWobble)
    }
    
}
