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
    
    struct LastStampData {
        var stamp: BrushEngine2.Stamp
        var strokeDistance: TimeInterval
    }
    
    struct ProcessSegmentOutput {
        var stamps: [BrushEngine2.Stamp]
        var lastStampData: LastStampData?
        
        var hasUnfinalizedStamps: Bool
    }
    
}

// MARK: - NewBrushStrokeEngineStampProcessor

struct NewBrushStrokeEngineStampProcessor {
    
    private let strokeConfig: StrokeConfig
    
    private var segmentControlPointSamples: [BrushEngine2.Sample] = []
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
            let lastSample = segmentControlPointSamples.last
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
        
        if segmentControlPointSamples.isEmpty {
            segmentControlPointSamples = Array(
                repeating: sample,
                count: 4)
            
            return []
            
        } else {
            segmentControlPointSamples.removeFirst()
            segmentControlPointSamples.append(sample)
            
            let output = Self.processSegment(
                strokeConfig: strokeConfig,
                controlPointSamples: segmentControlPointSamples,
                lastStampData: lastStampData)
            
            lastStampData = output.lastStampData
            
            if output.hasUnfinalizedStamps {
                isOutputFinalized = false
            }
            
            return output.stamps
        }
    }
    
    private static func processSegment(
        strokeConfig: StrokeConfig,
        controlPointSamples: [BrushEngine2.Sample],
        lastStampData: LastStampData?
    ) -> ProcessSegmentOutput {
        
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
            strokeConfig: strokeConfig,
            subSegmentSamples: subSegmentSamples,
            lastStampData: lastStampData)
    }
    
    private static func processSegment(
        strokeConfig: StrokeConfig,
        subSegmentSamples: [BrushEngine2.Sample],
        lastStampData: LastStampData?
    ) -> ProcessSegmentOutput {
        
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
                strokeConfig: strokeConfig,
                startSample: startSample,
                endSample: endSample,
                lastStampData: lastStampData)
            
            stamps += subSegmentOutput.stamps
            
            if let d = subSegmentOutput.lastStampData {
                lastStampData = d
            }
            if subSegmentOutput.hasUnfinalizedStamps {
                hasUnfinalizedStamps = true
            }
        }
        
        return ProcessSegmentOutput(
            stamps: stamps,
            lastStampData: lastStampData,
            hasUnfinalizedStamps: hasUnfinalizedStamps)
    }
    
    private static func processSubSegment(
        strokeConfig: StrokeConfig,
        startSample: BrushEngine2.Sample,
        endSample: BrushEngine2.Sample,
        lastStampData: LastStampData?
    ) -> ProcessSegmentOutput {
        
        // TODO: Actually interpolate between samples
        
        let stamp1 = Self.createStamp(
            strokeConfig: strokeConfig,
            sample: startSample)
        
        let stamp2 = Self.createStamp(
            strokeConfig: strokeConfig,
            sample: endSample)
        
        return ProcessSegmentOutput(
            stamps: [stamp1, stamp2],
            lastStampData: nil,
            hasUnfinalizedStamps: false)
    }
    
    private static func createStamp(
        strokeConfig: StrokeConfig,
        sample s: BrushEngine2.Sample
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
    
}
