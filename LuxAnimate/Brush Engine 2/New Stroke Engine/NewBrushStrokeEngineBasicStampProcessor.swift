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
        sample: BrushEngine2.Sample
    ) -> [BrushEngine2.Stamp] {
        
        let stamp = Self.stamp(
            sample: sample,
            brush: brush,
            scale: scale,
            color: color)
        
        return [stamp]
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
        
        var stamp = BrushEngine2.Stamp(
            position: sample.position,
            size: scaledBrushSize,
            rotation: 0,
            alpha: 1,
            color: color,
            offset: .zero,
            isFinalized: sample.isFinalized)
        
        if sample.isLastSample {
            stamp.size *= 3
            stamp.isFinalized = false
        }
        
        if AppConfig.brushRenderDebug,
            !stamp.isFinalized
        {
            stamp.color = AppConfig.strokeDebugColor
        }
        
        return stamp
    }
    
}
