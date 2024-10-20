//
//  NewBrushStrokeEngineStampProcessor.swift
//

import Foundation

private let minStampSize: Double = 0.5

struct NewBrushStrokeEngineStampProcessor {
    
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
