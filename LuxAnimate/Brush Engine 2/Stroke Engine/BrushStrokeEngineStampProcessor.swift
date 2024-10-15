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
        input: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Stamp] {
        
        return input.map { s in
            BrushEngine2.Stamp(
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
