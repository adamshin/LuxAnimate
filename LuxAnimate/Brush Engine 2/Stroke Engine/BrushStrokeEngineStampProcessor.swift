//
//  BrushStrokeEngineStampProcessor.swift
//

import Foundation

private let minStampSize: Double = 0.5

class BrushStrokeEngineStampProcessor {
    
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
    
    func process(
        input: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Stamp] {
        
        let scaledBrushSize = map(
            scale,
            in: (0, 1),
            to: (minStampSize, brush.config.stampSize))
        
        return input.map { s in
            BrushEngine2.Stamp(
                position: s.position,
                size: scaledBrushSize,
                rotation: 0,
                alpha: 0.2,
                color: color,
                offset: .zero,
                strokeDistance: 0,
                isFinalized: s.isFinalized)
        }
    }
    
}
