//
//  NewBrushStrokeEngineStampProcessor.swift
//

import Foundation

// MARK: - Config

private let minStampDistance: Double = 1.0
private let minStampSize: Double = 0.5

private let segmentSubdivisionCount = 1

// MARK: - Helpers

extension NewBrushStrokeEngineStampProcessor {
    
    struct StrokeConfig {
        var brush: Brush
        var scale: Double
        var color: Color
        var applyTaper: Bool
    }
    
    struct Segment {
        var controlPointSamples: [BrushEngine2.Sample]
        var startStrokeDistance: Double
    }
    
    struct LastStampData {
        var strokeDistance: Double
        var distanceToNextStamp: Double
    }
    
    struct ProcessSegmentOutput {
        var segmentLength: Double
        var stamps: [BrushEngine2.Stamp]
        var lastStampData: LastStampData?
        var hasUnfinalizedStamps: Bool
    }
    
    struct ProcessSubSegmentOutput {
        var subSegmentLength: Double
        var stamps: [BrushEngine2.Stamp]
        var lastStampData: LastStampData?
        var hasUnfinalizedStamps: Bool
    }
    
}

// MARK: - NewBrushStrokeEngineStampProcessor

struct NewBrushStrokeEngineStampProcessor {
    
    private let strokeConfig: StrokeConfig
    
    private var currentSegment: Segment?
    private var lastStampData: LastStampData?
    
    private var isOutputFinalized = true
    
    // MARK: - Init
    
    init(
        brush: Brush,
        scale: Double,
        color: Color,
        applyTaper: Bool
    ) {
        strokeConfig = StrokeConfig(
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
        
        for sample in input.samples {
            outputStamps += processSample(sample: sample)
        }
        
        if input.isStrokeEnd,
            let segmentData = currentSegment,
            let lastSample = segmentData.controlPointSamples.last
        {
            isOutputFinalized = false
            for _ in 0 ..< 2 {
                outputStamps += processSample(sample: lastSample)
            }
        }
        
        return NewBrushStrokeEngine.StampProcessorOutput(
            stamps: outputStamps,
            isFinalized: isOutputFinalized,
            isStrokeEnd: input.isStrokeEnd)
    }
    
    // MARK: - Internal Logic
    
    private mutating func processSample(
        sample: BrushEngine2.Sample
    ) -> [BrushEngine2.Stamp] {
        
        // TODO: Make this static, and have it return a
        // result object, instead of mutating?
        
        // When do we calculate segment length?
        // Are we storing the "active segment", or the "next segment"?
        // I'm unclear what my thoughts are here.
        
        if var currentSegment {
            currentSegment.controlPointSamples.removeFirst()
            currentSegment.controlPointSamples.append(sample)
            self.currentSegment = currentSegment
            
            let output = Self.processSegment(
                segment: currentSegment,
                lastStampData: lastStampData,
                strokeConfig: strokeConfig)
            
            lastStampData = output.lastStampData
            
            if output.hasUnfinalizedStamps {
                isOutputFinalized = false
            }
            
            return output.stamps
            
        } else {
            let controlPointSamples = Array(
                repeating: sample,
                count: 4)
            
            currentSegment = Segment(
                controlPointSamples: controlPointSamples,
                startStrokeDistance: 0)
        }
    }
    
    private static func processSegment(
        segment: Segment,
        lastStampData: LastStampData?,
        strokeConfig: StrokeConfig
    ) -> ProcessSegmentOutput {
        
        let controlPointSamples = segment.controlPointSamples
        guard controlPointSamples.count == 4 else {
            fatalError()
        }
        
        let s0 = controlPointSamples[0]
        let s1 = controlPointSamples[1]
        let s2 = controlPointSamples[2]
        let s3 = controlPointSamples[3]
        
        var subSegmentSamples: [BrushEngine2.Sample] = []
        
        for i in 0 ... segmentSubdivisionCount {
            let t = Double(i) / Double(segmentSubdivisionCount)
            
            let (b0, b1, b2, b3) =
                UniformCubicBSpline.basisValues(t: t)
            
            let sample = BrushEngineSampleInterpolator
                .interpolate([
                    (s0, b0),
                    (s1, b1),
                    (s2, b2),
                    (s3, b3),
                ])
            
            if let sample {
                subSegmentSamples.append(sample)
            }
        }
        
        return Self.processSegment(
            segmentStartStrokeDistance: segment.startStrokeDistance,
            subSegmentSamples: subSegmentSamples,
            lastStampData: lastStampData,
            strokeConfig: strokeConfig)
    }
    
    private static func processSegment(
        segmentStartStrokeDistance: Double,
        subSegmentSamples: [BrushEngine2.Sample],
        lastStampData: LastStampData?,
        strokeConfig: StrokeConfig
    ) -> ProcessSegmentOutput {
        
        var segmentLength: Double = 0
        var stamps: [BrushEngine2.Stamp] = []
        var lastStampData = lastStampData
        var hasUnfinalizedStamps = false
        
        guard subSegmentSamples.count >= 2 else {
            fatalError()
        }
        
        for i in 0 ..< subSegmentSamples.count - 1 {
            let startSample = subSegmentSamples[i]
            let endSample = subSegmentSamples[i + 1]
            
            let subSegmentOutput = Self.processSubSegment(
                startSample: startSample,
                endSample: endSample,
                startSampleStrokeDistance: 0,
                endSampleStrokeDistance: 0,
                lastStampData: lastStampData,
                strokeConfig: strokeConfig)
            
            stamps += subSegmentOutput.stamps
            
            if let d = subSegmentOutput.lastStampData {
                lastStampData = d
            }
            if subSegmentOutput.hasUnfinalizedStamps {
                hasUnfinalizedStamps = true
            }
        }
        
        return ProcessSegmentOutput(
            segmentLength: segmentLength,
            stamps: stamps,
            lastStampData: lastStampData,
            hasUnfinalizedStamps: hasUnfinalizedStamps)
    }
    
    private static func processSubSegment(
        startSample: BrushEngine2.Sample,
        endSample: BrushEngine2.Sample,
        startSampleStrokeDistance: Double,
        endSampleStrokeDistance: Double,
        lastStampData inputLastStampData: LastStampData?,
        strokeConfig: StrokeConfig
    ) -> ProcessSegmentOutput {
        
        var stamps: [BrushEngine2.Stamp] = []
        var hasUnfinalizedStamps = false
        
        var lastStampData: LastStampData
        if let inputLastStampData {
            lastStampData = inputLastStampData
            
        } else {
            let stamp = Self.createStamp(
                strokeConfig: strokeConfig,
                sample: startSample,
                strokeDistance: 0)
            
            stamps.append(stamp)
            
            let distanceToNextStamp = Self
                .distanceToNextStamp(
                    stamp: stamp,
                    brush: strokeConfig.brush)
            
            lastStampData = LastStampData(
                strokeDistance: 0,
                distanceToNextStamp: distanceToNextStamp)
        }
        
        while true {
            // Do stuff
        }
        
        return ProcessSubSegmentOutput(
            stamps: stamps,
            lastStampData: lastStampData,
            hasUnfinalizedStamps: hasUnfinalizedStamps)
    }
    
    private static func createStamp(
        strokeConfig: StrokeConfig,
        sample s: BrushEngine2.Sample,
        strokeDistance: Double
    ) -> BrushEngine2.Stamp {
        
        let scaledBrushSize = map(
            strokeConfig.scale,
            in: (0, 1),
            to: (
                minStampSize,
                strokeConfig.brush.config.stampSize
            ))
        
        return BrushEngine2.Stamp(
            position: s.position,
            size: scaledBrushSize,
            rotation: 0,
            alpha: 1,
            color: strokeConfig.color,
            offset: .zero)
    }
    
    private static func distanceToNextStamp(
        stamp: BrushEngine2.Stamp,
        brush: Brush
    ) -> Double {
        max(
            stamp.size * brush.config.stampSpacing,
            minStampDistance)
    }
    
}
