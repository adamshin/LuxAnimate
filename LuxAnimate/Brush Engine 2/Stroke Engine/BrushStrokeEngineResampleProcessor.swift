//
//  BrushStrokeEngineResampleProcessor.swift
//

import Foundation

private let sampleRate = 240
private let sampleTimestep = 1 / Double(sampleRate)

class BrushStrokeEngineResampleProcessor {
    
    struct State {
        var inputQueue: [BrushStrokeEngine2.Sample]
        // TODO: 4 recent samples?
        // TODO: time offset cursor?
    }
    
    private var lastFinalizedState: State
    
    init() {
        lastFinalizedState = State(inputQueue: [])
    }
    
    func process(
        input: BrushStrokeEngine2.ProcessorOutput
    ) -> BrushStrokeEngine2.ProcessorOutput {
        
        return BrushStrokeEngine2.ProcessorOutput()
    }
    
}
