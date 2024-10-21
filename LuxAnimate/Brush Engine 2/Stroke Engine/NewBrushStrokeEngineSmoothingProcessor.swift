//
//  NewBrushStrokeEngineSmoothingProcessor.swift
//

import Foundation

// MARK: - Config

private let maxWindowTime: TimeInterval = 0.4

private let sampleFillInterval: TimeInterval = 1/60

// MARK: - NewBrushStrokeEngineSmoothingProcessor

struct NewBrushStrokeEngineSmoothingProcessor {
    
    private let windowTime: TimeInterval
    
    private var sampleBuffer: [BrushEngine2.Sample] = []
    private var isOutputFinalized = true
    
    // MARK: - Init
    
    init(
        smoothing: Double
    ) {
        let s = clamp(smoothing, min: 0, max: 1)
        windowTime = s * maxWindowTime
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: NewBrushStrokeEngine.ProcessorOutput
    ) -> NewBrushStrokeEngine.ProcessorOutput {
        
        if !input.isFinalized {
            isOutputFinalized = false
        }
        
        var outputSamples: [BrushEngine2.Sample] = []
        
        Self.processSamples(
            samples: input.samples,
            strokeEndTime: input.strokeEndTime,
            sampleBuffer: &sampleBuffer,
            isOutputFinalized: &isOutputFinalized,
            outputSamples: &outputSamples)
        
        if input.isStrokeEnd {
            Self.processStrokeEnd(
                strokeEndTime: input.strokeEndTime,
                sampleBuffer: &sampleBuffer,
                isOutputFinalized: &isOutputFinalized,
                outputSamples: &outputSamples)
        }
        
        return NewBrushStrokeEngine.ProcessorOutput(
            samples: outputSamples,
            isFinalized: isOutputFinalized,
            isStrokeEnd: input.isStrokeEnd,
            strokeEndTime: input.strokeEndTime)
    }
    
    // MARK: - Internal Logic
    
    private static func processSamples(
        samples: [BrushEngine2.Sample],
        strokeEndTime: TimeInterval,
        sampleBuffer: inout [BrushEngine2.Sample],
        isOutputFinalized: inout Bool,
        outputSamples: inout [BrushEngine2.Sample]
    ) {
        for sample in samples {
            Self.processSample(
                sample: sample,
                strokeEndTime: strokeEndTime,
                sampleBuffer: &sampleBuffer,
                isOutputFinalized: &isOutputFinalized,
                outputSamples: &outputSamples)
        }
    }
    
    private static func processStrokeEnd(
        strokeEndTime: TimeInterval,
        sampleBuffer: inout [BrushEngine2.Sample],
        isOutputFinalized: inout Bool,
        outputSamples: inout [BrushEngine2.Sample]
    ) {
        isOutputFinalized = false
        
        // TODO: Generate stroke tail.
        
        // Take the last sample from the sample buffer,
        // repeat it and feed it through until it
        // flushes out all other samples.
        
        // Advance the time offset by the fill interval
        // each time.
    }
    
    private static func processSample(
        sample: BrushEngine2.Sample,
        strokeEndTime: TimeInterval,
        sampleBuffer: inout [BrushEngine2.Sample],
        isOutputFinalized: inout Bool,
        outputSamples: inout [BrushEngine2.Sample]
    ) {
        // Append the sample to the sample buffer.
        
        // Remove unneeded samples from the front of the
        // sample buffer (anything outside the time window).
        
        // Take a weighted average of the samples in the
        // buffer using parabolic curve weights. Gonna have
        // to figure out the math for this. Take a single
        // weight per sample? Integrate the area under the
        // parabola? It would be simpler to avoid calculus.
        // How to elegantly handle this?
        
        // If we try to read a sample from before the start
        // of the buffer, use the first sample instead.
    }
    
}
