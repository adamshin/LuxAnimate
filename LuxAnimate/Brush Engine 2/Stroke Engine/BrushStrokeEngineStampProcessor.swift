//
//  BrushStrokeEngineStampProcessor.swift
//

import Foundation

private let minStampSize: Double = 0.5
private let segmentInterpolationCount = 100

// I think I know what the issue with stroke finalization is.

// Samples are going into the segment control points list
// and once they've been "consumed", they never get updated.
// Or is this the issue? Does that make sense? If a non-
// finalized sample is consumed, the output should always
// be non-finalized. Meaning we don't save state at that
// point. Maybe I'm mixed up.

// Update: I fixed the issue with pencil input by NOT
// saving finalized state immediately after updating the
// input queue. But this makes quick tap finger input
// disappear. I think I need to think this through better.

// We need to treat input and output as "progressing"
// independently. Samples get added to the queue, stamps
// get output. The processor eats its way through its
// input stack. But should the input queue be part of the
// stored state?

// Maybe I need a different mental model. I'm not clear on
// how I want this to all work yet.

extension BrushStrokeEngineStampProcessor {
    
    struct State {
        var inputQueue: [BrushEngine2.Sample]
        
        var segmentControlPoints: [BrushEngine2.Sample]
        
        // TODO: Last stamp position?
        // Total stroke distance?
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
        
        var state: State
        
        if let lastFinalizedState {
            state = lastFinalizedState
            state.inputQueue.removeAll { !$0.isFinalized }
            state.inputQueue += input
            
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
        }
        
        var output: [BrushEngine2.Stamp] = []
        var isCumulativeOutputFinalized = true
        
        while let sample = state.inputQueue.first {
            state.inputQueue.removeFirst()
            
            state.segmentControlPoints.removeFirst()
            state.segmentControlPoints.append(sample)
            
            let segmentOutput = processSegment(
                controlPoints: state.segmentControlPoints)
            
            output += segmentOutput
            
            let outputFinalized = segmentOutput
                .allSatisfy { $0.isFinalized }
            
            if outputFinalized {
                if !isCumulativeOutputFinalized {
                    print("Output finalization inversion!")
                }
            } else {
                isCumulativeOutputFinalized = false
            }
            if isCumulativeOutputFinalized {
                lastFinalizedState = state
            }
        }
        
        var endSample = state.segmentControlPoints.last!
        endSample.isFinalized = false
        
        for _ in 0 ..< 2 {
            state.segmentControlPoints.removeFirst()
            state.segmentControlPoints.append(endSample)
            
            let segmentOutput = processSegment(
                controlPoints: state.segmentControlPoints)
            
            output += segmentOutput
            
            if segmentOutput.allSatisfy({ $0.isFinalized }) {
                lastFinalizedState = state
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
                scale: scale,
                color: color)
            
            output.append(stamp)
        }
        
        // TESTING
        for s in controlPoints {
            let stamp = Self.stamp(
                sample: s,
                brush: brush,
                scale: scale * 2,
                color: .debugRed.withAlpha(0.2))
            
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
            s.color = Color.strokeDebug
        }
        
        return s
    }
    
}
