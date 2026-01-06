
import Foundation
import Geometry
import Color

private let segmentSubdivisionCount = 10

struct StrokeEngineStrokeSampleProcessor {
    
    private let strokeSampleGenerator:
        StrokeEngineStrokeSampleGenerator
    
    private var controlPointSamples: [IntermediateSample] = []
    private var finalSampleTime: TimeInterval = 0
    
    private var lastOutputSample: StrokeSample?
    
    private var isOutputFinalized = true
    
    // MARK: - Init
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        applyTaper: Bool
    ) {
        strokeSampleGenerator = .init(
            brush: brush,
            scale: scale,
            applyTaper: applyTaper)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: IntermediateSampleBatch
    ) -> StrokeSampleBatch {
        
        finalSampleTime = input.finalSampleTime
        
        if !input.isFinalized {
            isOutputFinalized = false
        }
        
        var output: [StrokeSample] = []
        
        processSamples(
            samples: input.samples,
            output: &output)
        
        if input.isFinalBatch {
            isOutputFinalized = false
            processEndOfSamples(output: &output)
        }
        
        return StrokeSampleBatch(
            samples: output,
            isFinalBatch: input.isFinalBatch,
            isFinalized: isOutputFinalized)
    }
    
    // MARK: - Internal Logic
    
    private mutating func processSamples(
        samples: [IntermediateSample],
        output: inout [StrokeSample]
    ) {
        for sample in samples {
            processSample(
                sample: sample,
                output: &output)
        }
    }
    
    private mutating func processEndOfSamples(
        output: inout [StrokeSample]
    ) {
        guard let finalSample = controlPointSamples.last
        else { return }
        
        for _ in 0 ..< 3 {
            processSample(
                sample: finalSample,
                output: &output)
        }
    }
    
    private mutating func processSample(
        sample: IntermediateSample,
        output: inout [StrokeSample]
    ) {
        if controlPointSamples.isEmpty {
            controlPointSamples = Array(
                repeating: sample, count: 4)
            
        } else {
            controlPointSamples.removeFirst()
            controlPointSamples.append(sample)
        }
        
        processSplineSegment(output: &output)
    }
    
    private mutating func processSplineSegment(
        output: inout [StrokeSample]
    ) {
        let subSegmentSamples = Self.subSegmentSamples(
            controlPointSamples: controlPointSamples,
            subdivisionCount: segmentSubdivisionCount)
        
        for sample in subSegmentSamples {
            processSubSegmentSample(
                sample: sample,
                output: &output)
        }
    }
    
    private mutating func processSubSegmentSample(
        sample: IntermediateSample,
        output: inout [StrokeSample]
    ) {
        let strokeDistance: Double
        
        if let lastOutputSample {
            let positionDelta =
                sample.position -
                lastOutputSample.position
            
            let distanceFromLastStrokeSample =
                positionDelta.length()
            
            strokeDistance =
                lastOutputSample.strokeDistance +
                distanceFromLastStrokeSample
            
        } else {
            strokeDistance = 0
        }
        
        let strokeSampleOutput = strokeSampleGenerator
            .strokeSample(
                sample: sample,
                strokeDistance: strokeDistance,
                finalSampleTime: finalSampleTime)
        
        let strokeSample = strokeSampleOutput.strokeSample
        
        output.append(strokeSample)
        self.lastOutputSample = strokeSample
        
        if strokeSampleOutput.isNonFinalized {
            isOutputFinalized = false
        }
    }
    
    private static func subSegmentSamples(
        controlPointSamples: [IntermediateSample],
        subdivisionCount: Int
    ) -> [IntermediateSample] {
        
        guard controlPointSamples.count == 4 else {
            fatalError()
        }
        let s0 = controlPointSamples[0]
        let s1 = controlPointSamples[1]
        let s2 = controlPointSamples[2]
        let s3 = controlPointSamples[3]
        
        let count = segmentSubdivisionCount
        
        var output: [IntermediateSample] = []
        output.reserveCapacity(count)
        
        for i in 0 ..< count {
            let t = Double(i) / Double(count)
            
            let (b0, b1, b2, b3) =
                UniformCubicBSpline.basisValues(t: t)
            
            let sample = try! interpolate(
                v0: s0, v1: s1, v2: s2, v3: s3,
                w0: b0, w1: b1, w2: b2, w3: b3)
            
            output.append(sample)
        }
        return output
    }
    
}
