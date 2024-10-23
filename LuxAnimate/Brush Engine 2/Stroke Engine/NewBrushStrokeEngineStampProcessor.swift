//
//  NewBrushStrokeEngineStampProcessor.swift
//

import Foundation

private let segmentSubdivisionCount = 10

private let drawControlPoints = false

// MARK: - Structs

extension NewBrushStrokeEngineStampProcessor {
    
    struct Config {
        var stampGenerator: NewBrushStrokeEngineStampGenerator
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
        var controlPointSamples: [BrushEngine2.Sample]
        var subSegments: [SubSegment]
        var startStrokeDistance: Double
        var length: Double
    }
    
    struct SubSegment {
        var startSample: BrushEngine2.Sample
        var endSample: BrushEngine2.Sample
        var startStrokeDistance: Double
        var length: Double
    }
    
}

// MARK: - NewBrushStrokeEngineStampProcessor

struct NewBrushStrokeEngineStampProcessor {
    
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
            NewBrushStrokeEngineStampGenerator(
                brush: brush,
                scale: scale,
                color: color,
                applyTaper: applyTaper)
        
        config = Config(
            stampGenerator: stampGenerator)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: NewBrushStrokeEngine.ProcessorOutput
    ) -> NewBrushStrokeEngine.StampProcessorOutput {
        
        if !input.isFinalized {
            state.isOutputFinalized = false
        }
        
        var outputStamps: [BrushEngine2.Stamp] = []
        
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
        
        return NewBrushStrokeEngine.StampProcessorOutput(
            stamps: outputStamps,
            isFinalized: state.isOutputFinalized,
            isStrokeEnd: input.isStrokeEnd)
    }
    
    // MARK: - Internal Logic
    
    private static func processSample(
        config: Config,
        sample: BrushEngine2.Sample,
        strokeEndTime: TimeInterval,
        state: inout State,
        outputStamps: inout [BrushEngine2.Stamp]
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
                controlPointSamples: controlPointSamples,
                startStrokeDistance: startStrokeDistance)
            
        } else {
            let controlPointSamples = Array(
                repeating: sample,
                count: 4)
            
            segment = createSegment(
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
        outputStamps: inout [BrushEngine2.Stamp]
    ) {
        if drawControlPoints {
            for s in segment.controlPointSamples {
                let stamp = BrushEngine2.Stamp(
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
        outputStamps: inout [BrushEngine2.Stamp]
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
            
            let s1 = subSegment.startSample
            let s2 = subSegment.endSample
            
            let sample = try! BrushEngineSampleInterpolator
                .interpolate(
                    samples: [s1, s2],
                    weights: [1-t, t])
            
            let stampOutput =
                config.stampGenerator.stamp(
                    sample: sample,
                    strokeDistance: nextStampStrokeDistance,
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
        controlPointSamples: [BrushEngine2.Sample],
        startStrokeDistance: Double
    ) -> Segment {
        
        let subSegments = subSegments(
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
        controlPointSamples: [BrushEngine2.Sample],
        segmentStartStrokeDistance: Double
    ) -> [SubSegment] {
        
        let subSegmentSamples = subSegmentSamples(
            controlPointSamples: controlPointSamples)
        
        guard subSegmentSamples.count >= 2 else {
            fatalError()
        }
        
        var output: [SubSegment] = []
        var startStrokeDistance = segmentStartStrokeDistance
        
        for i in 0 ..< subSegmentSamples.count - 1 {
            let startSample = subSegmentSamples[i]
            let endSample = subSegmentSamples[i + 1]
            
            let positionDifference =
                endSample.position -
                startSample.position
            
            let length = positionDifference.length()
            
            let subSegment = SubSegment(
                startSample: startSample,
                endSample: endSample,
                startStrokeDistance: startStrokeDistance,
                length: length)
            
            output.append(subSegment)
            startStrokeDistance += length
        }
        return output
    }
    
    private static func subSegmentSamples(
        controlPointSamples: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Sample] {
        
        guard controlPointSamples.count == 4 else {
            fatalError()
        }
        let s0 = controlPointSamples[0]
        let s1 = controlPointSamples[1]
        let s2 = controlPointSamples[2]
        let s3 = controlPointSamples[3]
        
        let count = segmentSubdivisionCount
        
        var output: [BrushEngine2.Sample] = []
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
    
}
