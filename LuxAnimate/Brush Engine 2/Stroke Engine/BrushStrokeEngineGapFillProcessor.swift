//
//  BrushStrokeEngineGapFillProcessor.swift
//

import Foundation

class BrushStrokeEngineGapFillProcessor {
    
    static let fillTimeInterval: TimeInterval = 1/60
    static let currentTimeIntervalBackoff: Double = 1.5
    
    struct State {
        var inputQueue: [BrushEngine2.Sample] = []
        
        var cursorSample: BrushEngine2.Sample?
        var cursorTimeOffset: TimeInterval = 0
    }
    
    private var lastFinalizedState = State()
    
    func process(
        input: [BrushEngine2.Sample],
        currentTimeOffset: TimeInterval
    ) -> [BrushEngine2.Sample] {
        
        var state = lastFinalizedState
        state.inputQueue.removeAll { !$0.isFinalized }
        state.inputQueue += input
        
        var output: [BrushEngine2.Sample] = []
        
        while true {
            // Save finalized state if applicable
            if output.allSatisfy({ $0.isFinalized }) {
                lastFinalizedState = state
            }
            
            // Set first cursor sample if necessary
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
            
            // Move cursor ahead
            state.cursorTimeOffset += Self.fillTimeInterval
            
            // If there is a next sample, fill ahead to it.
            // If not, fill ahead to the current time.
            if let nextSample = state.inputQueue.first {
                if state.cursorTimeOffset >
                    nextSample.timeOffset
                    - Self.fillTimeInterval * 0.5
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
                if state.cursorTimeOffset >
                    currentTimeOffset
                    - Self.fillTimeInterval
                    * Self.currentTimeIntervalBackoff
                {
                    break
                    
                } else {
                    var sample = cursorSample
                    sample.timeOffset = state.cursorTimeOffset
                    output.append(sample)
                }
            }
        }
        
        return output
    }
    
}
