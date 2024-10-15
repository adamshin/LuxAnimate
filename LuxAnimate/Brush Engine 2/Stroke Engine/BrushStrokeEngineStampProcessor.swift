//
//  BrushStrokeEngineStampProcessor.swift
//

import Foundation

class BrushStrokeEngineStampProcessor {
    
    private let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    func process(
        input: [BrushStrokeEngine2.Sample]
    ) -> [BrushStrokeEngine2.Stamp] {
        
        return input.map { s in
            BrushStrokeEngine2.Stamp(
                position: s.position,
                size: 1,
                rotation: 0,
                alpha: 1,
                color: color,
                offset: .zero,
                strokeDistance: 0,
                isFinalized: s.isFinalized)
        }
    }
    
}
