//
//  BrushStrokeEngineStampProcessor.swift
//

import Foundation

private let minStampSize: Double = 0.5

extension BrushStrokeEngineStampProcessor {
    
    struct State {
        var inputQueue: [BrushEngine2.Sample]
        
        var segmentControlPoints: [BrushEngine2.Sample]
        
        // TODO: Last stamp position?
        // Total stroke distance?
        
        // Segment timing estimate data?
        // We may need to break the segment into a series
        // of line segments to properly calculate distance.
    }
    
}

class BrushStrokeEngineStampProcessor {
    
    private let brush: Brush
    private let scale: Double
    private let color: Color
    
    private var lastFinalizedState: State?
    
    init(
        brush: Brush,
        scale: Double,
        color: Color
    ) {
        self.brush = brush
        self.scale = scale
        self.color = color
    }
    
    func process(
        input: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Stamp] {
        
        print("""
            Processing samples. \
            \(input.count { $0.isFinalized }) finalized, \
            \(input.count { !$0.isFinalized }) nonfinalized
            """)
        
        var state: State
        
        if let lastFinalizedState {
            state = lastFinalizedState
            state.inputQueue.removeAll { !$0.isFinalized }
            state.inputQueue += input
            
            self.lastFinalizedState = state
            
            print("Updating state. Input queue size: \(state.inputQueue.count)")
            
        } else {
            guard let firstSample = input.first
            else { return [] }
            
            let inputQueue = Array(input.dropFirst())
            
            let segmentControlPoints = Array(
                repeating: firstSample,
                count: 4)
            
            state = State(
                inputQueue: inputQueue,
                segmentControlPoints: segmentControlPoints)
            
            lastFinalizedState = state
            
            print("Setting initial state. Input queue size: \(state.inputQueue.count)")
        }
        
        var output: [BrushEngine2.Stamp] = []
        
        while let sample = state.inputQueue.first {
            state.inputQueue.removeFirst()
            
            state.segmentControlPoints.removeFirst()
            state.segmentControlPoints.append(sample)
            
            let segmentOutput = processSegment(
                controlPoints: state.segmentControlPoints)
            
            output += segmentOutput
            
            if segmentOutput.allSatisfy({ $0.isFinalized }) {
                lastFinalizedState = state
            }
        }
        
        // TODO: Finish the tail of the curve.
        // Repeat the final sample 2 more times and process
        // these segments. This ensures the curve passes
        // through the end point.
        
        return output
    }
    
    private func processSegment(
        controlPoints: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Stamp] {
        
        guard controlPoints.count == 4
        else { return [] }
        
        let s0 = controlPoints[0]
        let s1 = controlPoints[1]
        let s2 = controlPoints[2]
        let s3 = controlPoints[3]
        
        var output: [BrushEngine2.Stamp] = []
        
        let interpolationCount = 10
        
        for i in 0 ..< interpolationCount {
            let t = Double(i) / Double(interpolationCount)
            
            let (b0, b1, b2, b3) =
                UniformCubicBSpline.basisValues(t: t)
            
            let sample = BrushStrokeEngineSampleInterpolator
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
                scale: i == 0 ? scale*2.5 : scale,
                color: i == 0 ? .brushGreen : color)
            
            output.append(stamp)
        }
        
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
            s.color = Color.debugRed
        }
        
        return s
    }
    
}
