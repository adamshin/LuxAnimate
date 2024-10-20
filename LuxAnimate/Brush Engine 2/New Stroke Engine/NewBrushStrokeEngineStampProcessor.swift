//
//  NewBrushStrokeEngineStampProcessor.swift
//

import Foundation

private let minStampSize: Double = 0.5
private let segmentInterpolationCount = 100

struct NewBrushStrokeEngineStampProcessor {
    
    private let brush: Brush
    private let scale: Double
    private let color: Color
    
    private var segmentControlPoints: [BrushEngine2.Sample] = []
    // TODO: Last stamp position?
    // Total stroke distance?
    
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
        sample: BrushEngine2.Sample
    ) -> [BrushEngine2.Stamp] {
        
        var output: [BrushEngine2.Stamp] = []
        
        if segmentControlPoints.isEmpty {
            segmentControlPoints = Array(
                repeating: sample,
                count: 4)
            
            // Here's a problem. At this point, we don't
            // return any stamps. If the first sample is
            // non-finalized, we don't want the stroke
            // engine to treat our output as finalized.
            // But there's no way to signal that, since
            // we're not returning anything.
            
        } else {
            segmentControlPoints.removeFirst()
            segmentControlPoints.append(sample)
            
            let segmentStamps = processSegment(
                controlPoints: segmentControlPoints)
            
            output += segmentStamps
        }
        
        if sample.isLastSample {
            var endSample = sample
            endSample.isFinalized = false
            
            for _ in 0 ..< 2 {
                segmentControlPoints.removeFirst()
                segmentControlPoints.append(endSample)
                
                let segmentOutput = processSegment(
                    controlPoints: segmentControlPoints)
                
                output += segmentOutput
            }
        }
        
        return output
    }
    
    private func processSegment(
        controlPoints: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Stamp] {
        
        guard controlPoints.count == 4 else {
            fatalError("""
                BrushStrokeEngineStampProcessor: \
                Wrong number of control points!
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
            
            let stamp = Self.stamp(
                sample: sample,
                brush: brush,
                scale: scale,
                color: color)
            
            output.append(stamp)
        }
        
        // TESTING
//        for s in controlPoints {
//            let stamp = Self.stamp(
//                sample: s,
//                brush: brush,
//                scale: scale * 2,
//                color: .debugGreen.withAlpha(0.5))
//            
//            output.append(stamp)
//        }
        
        return output
    }
    
    private static func stamp(
        sample s: BrushEngine2.Sample,
        brush: Brush,
        scale: Double,
        color: Color
    ) -> BrushEngine2.Stamp {
        
        let scaledBrushSize = map(
            scale,
            in: (0, 1),
            to: (minStampSize, brush.config.stampSize))
        
        var s = BrushEngine2.Stamp(
            position: s.position,
            size: scaledBrushSize,
            rotation: 0,
            alpha: 1,
            color: color,
            offset: .zero,
            isFinalized: s.isFinalized)
        
        if AppConfig.brushRenderDebug,
            !s.isFinalized
        {
            s.color = AppConfig.strokeDebugColor
        }
        
        return s
    }
    
}
