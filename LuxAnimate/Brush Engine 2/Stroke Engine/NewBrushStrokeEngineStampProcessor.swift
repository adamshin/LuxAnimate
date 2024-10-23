//
//  NewBrushStrokeEngineStampProcessor.swift
//

import Foundation

// MARK: - Config

private let segmentSubdivisionCount = 10

// MARK: - Structs

extension NewBrushStrokeEngineStampProcessor {
    
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
    
    struct LastStampData {
        var strokeDistance: Double
        var distanceToNextStamp: Double
    }
    
    struct ProcessSampleOutput {
        var segment: Segment
        var stamps: [BrushEngine2.Stamp]
        var lastStampData: LastStampData?
        var hasNonFinalizedStamps: Bool
    }
    
    struct ProcessSegmentOutput {
        var stamps: [BrushEngine2.Stamp]
        var lastStampData: LastStampData?
        var hasNonFinalizedStamps: Bool
    }
    
    struct CreateStampOutput {
        var stamp: BrushEngine2.Stamp
        var distanceToNextStamp: Double
        var isNonFinalized: Bool
    }
    
}

// MARK: - NewBrushStrokeEngineStampProcessor

struct NewBrushStrokeEngineStampProcessor {
    
    private let stampGenerator:
        NewBrushStrokeEngineStampGenerator
    
    private var lastSegment: Segment?
    private var lastStampData: LastStampData?
    
    private var isOutputFinalized = true
    
    // MARK: - Init
    
    init(
        brush: Brush,
        scale: Double,
        color: Color,
        applyTaper: Bool
    ) {
        stampGenerator = .init(
            brush: brush,
            scale: scale,
            color: color,
            applyTaper: applyTaper)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: NewBrushStrokeEngine.ProcessorOutput
    ) -> NewBrushStrokeEngine.StampProcessorOutput {
        
        if !input.isFinalized {
            isOutputFinalized = false
        }
        
        var outputStamps: [BrushEngine2.Stamp] = []
        
        Self.processSamples(
            samples: input.samples,
            strokeEndTime: input.strokeEndTime,
            stampGenerator: stampGenerator,
            lastSegment: &lastSegment,
            lastStampData: &lastStampData,
            isOutputFinalized: &isOutputFinalized,
            outputStamps: &outputStamps)
        
        if input.isStrokeEnd {
            isOutputFinalized = false
            
            Self.processStrokeEnd(
                strokeEndTime: input.strokeEndTime,
                stampGenerator: stampGenerator,
                lastSegment: &lastSegment,
                lastStampData: &lastStampData,
                isOutputFinalized: &isOutputFinalized,
                outputStamps: &outputStamps)
        }
        
        return NewBrushStrokeEngine.StampProcessorOutput(
            stamps: outputStamps,
            isFinalized: isOutputFinalized,
            isStrokeEnd: input.isStrokeEnd)
    }
    
    // MARK: - Internal Logic
    
    private static func processSamples(
        samples: [BrushEngine2.Sample],
        strokeEndTime: TimeInterval,
        stampGenerator: NewBrushStrokeEngineStampGenerator,
        lastSegment: inout Segment?,
        lastStampData: inout LastStampData?,
        isOutputFinalized: inout Bool,
        outputStamps: inout [BrushEngine2.Stamp]
    ) {
        for sample in samples {
            Self.processSample(
                sample: sample,
                strokeEndTime: strokeEndTime,
                stampGenerator: stampGenerator,
                lastSegment: &lastSegment,
                lastStampData: &lastStampData,
                isOutputFinalized: &isOutputFinalized,
                outputStamps: &outputStamps)
        }
    }
    
    private static func processStrokeEnd(
        strokeEndTime: TimeInterval,
        stampGenerator: NewBrushStrokeEngineStampGenerator,
        lastSegment: inout Segment?,
        lastStampData: inout LastStampData?,
        isOutputFinalized: inout Bool,
        outputStamps: inout [BrushEngine2.Stamp]
    ) {
        guard let lastSample = lastSegment?
            .controlPointSamples.last
        else { return }
        
        for _ in 0 ..< 2 {
            Self.processSample(
                sample: lastSample,
                strokeEndTime: strokeEndTime,
                stampGenerator: stampGenerator,
                lastSegment: &lastSegment,
                lastStampData: &lastStampData,
                isOutputFinalized: &isOutputFinalized,
                outputStamps: &outputStamps)
        }
    }
    
    private static func processSample(
        sample: BrushEngine2.Sample,
        strokeEndTime: TimeInterval,
        stampGenerator: NewBrushStrokeEngineStampGenerator,
        lastSegment: inout Segment?,
        lastStampData: inout LastStampData?,
        isOutputFinalized: inout Bool,
        outputStamps: inout [BrushEngine2.Stamp]
    ) {
        let sampleOutput = Self.processSample(
            sample: sample,
            strokeEndTime: strokeEndTime,
            stampGenerator: stampGenerator,
            lastSegment: lastSegment,
            lastStampData: lastStampData)
        
        outputStamps += sampleOutput.stamps
        
        lastSegment = sampleOutput.segment
        lastStampData = sampleOutput.lastStampData
        
        if sampleOutput.hasNonFinalizedStamps {
            isOutputFinalized = false
        }
    }
    
    private static func processSample(
        sample: BrushEngine2.Sample,
        strokeEndTime: TimeInterval,
        stampGenerator: NewBrushStrokeEngineStampGenerator,
        lastSegment: Segment?,
        lastStampData: LastStampData?
    ) -> ProcessSampleOutput {
        
        let segment: Segment
        
        if let lastSegment {
            var controlPointSamples =
                lastSegment.controlPointSamples
            
            controlPointSamples.removeFirst()
            controlPointSamples.append(sample)
            
            let startStrokeDistance =
                lastSegment.startStrokeDistance +
                lastSegment.length
            
            segment = Self.createSegment(
                controlPointSamples: controlPointSamples,
                startStrokeDistance: startStrokeDistance)
            
        } else {
            let controlPointSamples = Array(
                repeating: sample,
                count: 4)
            
            segment = Self.createSegment(
                controlPointSamples: controlPointSamples,
                startStrokeDistance: 0)
        }
            
        let segmentOutput = Self.processSegment(
            segment: segment,
            strokeEndTime: strokeEndTime,
            stampGenerator: stampGenerator,
            lastStampData: lastStampData)
        
        return ProcessSampleOutput(
            segment: segment,
            stamps: segmentOutput.stamps,
            lastStampData: segmentOutput.lastStampData,
            hasNonFinalizedStamps: segmentOutput.hasNonFinalizedStamps)
    }
    
    private static func processSegment(
        segment: Segment,
        strokeEndTime: TimeInterval,
        stampGenerator: NewBrushStrokeEngineStampGenerator,
        lastStampData: LastStampData?
    ) -> ProcessSegmentOutput {
        
        var stamps: [BrushEngine2.Stamp] = []
        var lastStampData = lastStampData
        var hasNonFinalizedStamps = false
        
        for subSegment in segment.subSegments {
            let subSegmentOutput = Self.processSubSegment(
                subSegment: subSegment,
                strokeEndTime: strokeEndTime,
                stampGenerator: stampGenerator,
                lastStampData: lastStampData)
            
            stamps += subSegmentOutput.stamps
            lastStampData = subSegmentOutput.lastStampData
            
            if subSegmentOutput.hasNonFinalizedStamps {
                hasNonFinalizedStamps = true
            }
        }
        
        return ProcessSegmentOutput(
            stamps: stamps,
            lastStampData: lastStampData,
            hasNonFinalizedStamps: hasNonFinalizedStamps)
    }
    
    private static func processSubSegment(
        subSegment: SubSegment,
        strokeEndTime: TimeInterval,
        stampGenerator: NewBrushStrokeEngineStampGenerator,
        lastStampData inputLastStampData: LastStampData?
    ) -> ProcessSegmentOutput {
        
        var stamps: [BrushEngine2.Stamp] = []
        var hasNonFinalizedStamps = false
        
        var lastStampData: LastStampData
        
        if let inputLastStampData {
            lastStampData = inputLastStampData
        } else {
            lastStampData = LastStampData(
                strokeDistance: 0,
                distanceToNextStamp: 0)
        }
        
        while true {
            let nextStampStrokeDistance =
                lastStampData.strokeDistance +
                lastStampData.distanceToNextStamp
            
            let nextStampDistanceInSubSegment =
                nextStampStrokeDistance -
                subSegment.startStrokeDistance
            
            if nextStampDistanceInSubSegment
                > subSegment.length + 0.001
            { break }
            
            let normalizedSubSegmentDistance: Double
            if subSegment.length != 0 {
                let d = nextStampDistanceInSubSegment /
                    subSegment.length
                normalizedSubSegmentDistance =
                    clamp(d, min: 0, max: 1)
            } else {
                normalizedSubSegmentDistance = 0
            }
            
            let w2 = normalizedSubSegmentDistance
            let w1 = 1 - w2
            
            let s1 = subSegment.startSample
            let s2 = subSegment.endSample
            
            let sample = try! BrushEngineSampleInterpolator
                .interpolate([
                    (s1, w1),
                    (s2, w2),
                ])
            
            let stampOutput =
                stampGenerator.stamp(
                    sample: sample,
                    strokeDistance: nextStampStrokeDistance,
                    strokeEndTime: strokeEndTime)
            
            let stamp = stampOutput.stamp
            stamps.append(stamp)
            
            if stampOutput.isNonFinalized {
                hasNonFinalizedStamps = true
            }
            
            let distanceToNextStamp =
                max(1.0, stampOutput.distanceToNextStamp)
            
            lastStampData = LastStampData(
                strokeDistance: nextStampStrokeDistance,
                distanceToNextStamp: distanceToNextStamp)
        }
        
        return ProcessSegmentOutput(
            stamps: stamps,
            lastStampData: lastStampData,
            hasNonFinalizedStamps: hasNonFinalizedStamps)
    }
    
    // MARK: - Segment
    
    private static func createSegment(
        controlPointSamples: [BrushEngine2.Sample],
        startStrokeDistance: Double
    ) -> Segment {
        
        let subSegmentSamples = Self.subSegmentSamples(
            controlPointSamples: controlPointSamples)
        
        let subSegments = Self.subSegments(
            subSegmentSamples: subSegmentSamples,
            segmentStartStrokeDistance: startStrokeDistance)
        
        let length = subSegments
            .map { $0.length }
            .reduce(0, +)
        
        return Segment(
            controlPointSamples: controlPointSamples,
            subSegments: subSegments,
            startStrokeDistance: startStrokeDistance,
            length: length)
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
        
        var output: [BrushEngine2.Sample] = []
        
        let count = segmentSubdivisionCount
        for i in 0 ... count {
            let t = Double(i) / Double(count)
            
            let (b0, b1, b2, b3) = UniformCubicBSpline
                .basisValues(t: t)
            
            let sample = try! BrushEngineSampleInterpolator
                .interpolate([
                    (s0, b0),
                    (s1, b1),
                    (s2, b2),
                    (s3, b3),
                ])
            
            output.append(sample)
        }
        return output
    }
    
    private static func subSegments(
        subSegmentSamples: [BrushEngine2.Sample],
        segmentStartStrokeDistance: Double
    ) -> [SubSegment] {
        
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
    
}
