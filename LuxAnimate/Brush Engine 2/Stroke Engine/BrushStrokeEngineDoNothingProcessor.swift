//
//  BrushStrokeEngineDoNothingProcessor.swift
//

import Foundation

struct BrushStrokeEngineDoNothingProcessor {
    
    mutating func process(
        _ inputSample: BrushStrokeEngine2.Sample
    ) -> [BrushStrokeEngine2.Sample] {
        
        return [inputSample]
    }
    
}
