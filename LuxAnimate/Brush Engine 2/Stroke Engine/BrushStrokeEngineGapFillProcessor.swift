//
//  BrushStrokeEngineGapFillProcessor.swift
//

import Foundation

class BrushStrokeEngineGapFillProcessor {
    
    static let fillTimeInterval: TimeInterval = 1/60
    
    struct State {
        var inputQueue: [BrushEngine2.Sample] = []
        
        var cursorSample: BrushEngine2.Sample?
        var cursorTimeOffset: TimeInterval = 0
    }
    
    private var lastFinalizedState = State()
    
    func process(
        input: [BrushEngine2.Sample]
    ) -> [BrushEngine2.Sample] {
        
        var state = lastFinalizedState
        state.inputQueue.removeAll { !$0.isFinalized }
        state.inputQueue += input
        
        var output: [BrushEngine2.Sample] = []
        
        while true {
            if output.allSatisfy({ $0.isFinalized }) {
                lastFinalizedState = state
            }
            
            guard let cursorSample = state.cursorSample else {
                if let nextSample = state.inputQueue.first {
                    state.inputQueue.removeFirst()
                    state.cursorSample = nextSample
                    state.cursorTimeOffset = nextSample.timeOffset
                    output.append(nextSample)
                    continue
                } else {
                    break
                }
            }
            
            state.cursorTimeOffset += Self.fillTimeInterval
            
            if let nextSample = state.inputQueue.first {
                if state.cursorTimeOffset
                    > nextSample.timeOffset
                    - Self.fillTimeInterval/2
                {
                    state.inputQueue.removeFirst()
                    state.cursorSample = nextSample
                    state.cursorTimeOffset = nextSample.timeOffset
                    output.append(nextSample)
                    
                } else {
                    var sample = cursorSample
                    sample.timeOffset = state.cursorTimeOffset
                    sample.isFinalized =
                        cursorSample.isFinalized &&
                        nextSample.isFinalized
                    
                    output.append(sample)
                }
                
            } else {
                // TODO: Fill forwards till current time.
                // Back off by one or two time intervals,
                // to make sure we don't overrun real
                // future data.
                
                // Maybe we can do this by taking a time
                // sample when process is called. Then
                // comparing in subsequent calls. I need to
                // think this through.
                
                break
            }
        }
        
        return output
    }
    
}
