//
//  NewBrushStrokeEngineStampProcessor.swift
//

import Foundation

private let minStampSize: Double = 0.5
private let segmentInterpolationCount = 10
private let stampAlpha: Double = 1

struct NewBrushStrokeEngineStampProcessor {
    
    private let brush: Brush
    private let scale: Double
    private let color: Color
    
    private var isOutputFinalized = true
    
    private var segmentControlPoints: [BrushEngine2.Sample] = []
    // TODO: Last stamp position?
    // Total stroke distance?
    
    private var totalSampleCount = 0
    
    init(
        brush: Brush,
        scale: Double,
        color: Color
    ) {
        self.brush = brush
        self.scale = scale
        self.color = color
    }
    
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
        
        if input.isStrokeEnd {
            isOutputFinalized = false
            outputStamps += processStrokeEnd()
        }
        
        return NewBrushStrokeEngine.StampProcessorOutput(
            stamps: outputStamps,
            isFinalized: isOutputFinalized,
            isStrokeEnd: input.isStrokeEnd)
    }
    
    private mutating func processSample(
        sample: BrushEngine2.Sample
    ) -> [BrushEngine2.Stamp] {
        
        if segmentControlPoints.isEmpty {
            segmentControlPoints = Array(
                repeating: sample,
                count: 4)
            
            return []
            
        } else {
            segmentControlPoints.removeFirst()
            segmentControlPoints.append(sample)
            
            return processSegment(
                controlPoints: segmentControlPoints)
        }
    }
    
    private mutating func processStrokeEnd()
    -> [BrushEngine2.Stamp] {
        
        guard let lastSample = segmentControlPoints.last
        else { return [] }
        
        var stamps: [BrushEngine2.Stamp] = []
        
        for _ in 0 ..< 2 {
            segmentControlPoints.removeFirst()
            segmentControlPoints.append(lastSample)
            
            stamps += processSegment(
                controlPoints: segmentControlPoints)
        }
        
        let lastStamp = createStamp(sample: lastSample)
        stamps.append(lastStamp)
        
        return stamps
    }
    
    private func processSegment(
        controlPoints: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Stamp] {
        
        guard controlPoints.count == 4 else {
            fatalError("""
                BrushStrokeEngineStampProcessor: \
                Expected 4 control points, \
                got \(controlPoints.count)
                """)
        }
        
        let s0 = controlPoints[0]
        let s1 = controlPoints[1]
        let s2 = controlPoints[2]
        let s3 = controlPoints[3]
        
        var output: [BrushEngine2.Stamp] = []
        
        let count = segmentInterpolationCount
        for i in 0 ..< count {
            let t = Double(i) / Double(count)
            
            let (b0, b1, b2, b3) =
                UniformCubicBSpline.basisValues(t: t)
            
            let sample = BrushEngineSampleInterpolator
                .interpolate([
                    (s0, b0),
                    (s1, b1),
                    (s2, b2),
                    (s3, b3),
                ])
            
            guard let sample else { continue }
            
            let stamp = createStamp(sample: sample)
            
            output.append(stamp)
        }
        
        return output
    }
    
    private func createStamp(
        sample s: BrushEngine2.Sample
    ) -> BrushEngine2.Stamp {
        
        let scaledBrushSize = map(
            scale,
            in: (0, 1),
            to: (minStampSize, brush.config.stampSize))
        
        return BrushEngine2.Stamp(
            position: s.position,
            size: scaledBrushSize,
            rotation: 0,
            alpha: stampAlpha,
            color: color,
            offset: .zero)
    }
    
}
