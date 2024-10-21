//
//  NewBrushStrokeEngineBasicStampProcessor.swift
//

import Foundation

private let minStampSize: Double = 0.5

struct NewBrushStrokeEngineBasicStampProcessor {
    
    private let brush: Brush
    private let scale: Double
    private let color: Color
    
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
        
        let stamps = input.samples.map {
            Self.stamp(
                sample: $0,
                brush: brush,
                scale: scale,
                color: color)
        }
        
        return NewBrushStrokeEngine.StampProcessorOutput(
            stamps: stamps,
            isFinalized: input.isFinalized,
            isStrokeEnd: input.isStrokeEnd)
    }
    
    private static func stamp(
        sample: BrushEngine2.Sample,
        brush: Brush,
        scale: Double,
        color: Color
    ) -> BrushEngine2.Stamp {
        
        let scaledBrushSize = map(
            scale,
            in: (0, 1),
            to: (minStampSize, brush.config.stampSize))
        
        return BrushEngine2.Stamp(
            position: sample.position,
            size: scaledBrushSize,
            rotation: 0,
            alpha: 1,
            color: color,
            offset: .zero)
    }
    
}
