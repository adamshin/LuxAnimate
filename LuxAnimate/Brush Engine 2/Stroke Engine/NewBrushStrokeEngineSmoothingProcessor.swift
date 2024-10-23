//
//  NewBrushStrokeEngineSmoothingProcessor.swift
//

import Foundation

// MARK: - Config

private let maxWindowSize: TimeInterval = 0.4

private let resampleInterval: TimeInterval = 1/240
private let minResampleCount = 10

private let strokeTailSampleInterval: TimeInterval = 1/60

// MARK: - NewBrushStrokeEngineSmoothingProcessor

struct NewBrushStrokeEngineSmoothingProcessor {
    
    private let windowSize: TimeInterval
    
    private var sampleBuffer: [BrushEngine2.Sample] = []
    private var isOutputFinalized = true
    
    // MARK: - Init
    
    init(
        smoothing: Double
    ) {
        let s = clamp(smoothing, min: 0, max: 1)
        windowSize = s * maxWindowSize
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
            windowSize: windowSize,
            sampleBuffer: &sampleBuffer,
            outputSamples: &outputSamples)
        
        if input.isStrokeEnd {
            isOutputFinalized = false
            
            Self.processStrokeEnd(
                strokeEndTime: input.strokeEndTime,
                windowSize: windowSize,
                sampleBuffer: &sampleBuffer,
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
        windowSize: TimeInterval,
        sampleBuffer: inout [BrushEngine2.Sample],
        outputSamples: inout [BrushEngine2.Sample]
    ) {
        for sample in samples {
            addSampleToBuffer(
                sample: sample,
                windowSize: windowSize,
                sampleBuffer: &sampleBuffer)
            
            let newSample = Self.sample(
                windowSize: windowSize,
                windowEndTime: sample.time,
                sampleBuffer: sampleBuffer)
            
            outputSamples.append(newSample)
        }
    }
    
    private static func processStrokeEnd(
        strokeEndTime: TimeInterval,
        windowSize: TimeInterval,
        sampleBuffer: inout [BrushEngine2.Sample],
        outputSamples: inout [BrushEngine2.Sample]
    ) {
        guard let lastSample = sampleBuffer.last
        else { return }
        
        let windowEndTargetTime =
            lastSample.time + windowSize
        
        var windowEndTime = lastSample.time
        
        while windowEndTime < windowEndTargetTime {
            windowEndTime += strokeTailSampleInterval
            
            let newSample = Self.sample(
                windowSize: windowSize,
                windowEndTime: windowEndTime,
                sampleBuffer: sampleBuffer)
            
            outputSamples.append(newSample)
        }
    }
    
    private static func addSampleToBuffer(
        sample: BrushEngine2.Sample,
        windowSize: TimeInterval,
        sampleBuffer: inout [BrushEngine2.Sample]
    ) {
        sampleBuffer.append(sample)
        
        let windowStartTime = sample.time - windowSize
        
        let outsideWindowCount = sampleBuffer
            .prefix { $0.time > windowStartTime }
            .count
        
        let removeCount = max(0, outsideWindowCount - 1)
        
        sampleBuffer.removeFirst(removeCount)
    }
    
    private static func sample(
        windowSize: TimeInterval,
        windowEndTime: TimeInterval,
        sampleBuffer: [BrushEngine2.Sample]
    ) -> BrushEngine2.Sample {
        
        let resampleTimes = resampleTimes(
            windowSize: windowSize,
            windowEndTime: windowEndTime)
        
        let windowSamples =
            try! NewBrushStrokeEngineSampleResampler
                .resample(
                    samples: sampleBuffer,
                    resampleTimes: resampleTimes)
        
        return weightedAverageSample(
            windowSamples: windowSamples)
    }
    
    private static func resampleTimes(
        windowSize: TimeInterval,
        windowEndTime: TimeInterval
    ) -> [TimeInterval] {
        
        if windowSize < 0.001 {
            return [windowEndTime]
        }
        
        let timeCount = max(
            minResampleCount,
            Int(windowSize / resampleInterval))
        
        return (0 ..< timeCount).map { i in
            let c = Double(i) / Double(timeCount - 1)
            return windowEndTime - c * windowSize
        }
    }
    
    private static func weightedAverageSample(
        windowSamples: [BrushEngine2.Sample]
    ) -> BrushEngine2.Sample {
        
        guard !windowSamples.isEmpty
        else { fatalError() }
        
        var samplesAndWeights:
            [(BrushEngine2.Sample, Double)] = []
        
        samplesAndWeights.reserveCapacity(
            windowSamples.count)
        
        for i in 0 ..< windowSamples.count {
            let sample = windowSamples[i]
            
            let weight = windowWeight(
                index: i,
                count: windowSamples.count)
            
            samplesAndWeights.append((sample, weight))
        }
        
        return try! BrushEngineSampleInterpolator
            .interpolate(samplesAndWeights)
    }
    
    // MARK: - Window Weights
    
    private static func windowWeight(
        index: Int, count: Int
    ) -> Double {
        windowWeightParabola(index: index, count: count)
    }
    
    private static func windowWeightFlat(
        index: Int, count: Int
    ) -> Double {
        return 1
    }
    
    private static func windowWeightParabola(
        index: Int, count: Int
    ) -> Double {
        if count <= 3 { return 1 }
        
        let p = Double(index) / Double(count - 1)
        let x = (p * 2) - 1
        return 1 - (x * x)
    }
    
}
