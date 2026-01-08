
import Foundation

private let maxWindowSize: TimeInterval = 0.4

private let resampleInterval: TimeInterval = 1/240
private let minResampleCount = 10
private let maxResampleCount = 100

private let tailSampleInterval: TimeInterval = 1/60

/// Applies temporal smoothing to samples using a parabola-shaped weighted averaging window.

struct StrokeEngineSmoothingProcessor {

    private let windowSize: TimeInterval
    private let resampleTimeOffsets: [Double]
    private let windowWeights: [Double]

    private var sampleBuffer: [IntermediateSample] = []
    private var isOutputFinalized = true

    // MARK: - Init

    init(
        brush: Brush,
        smoothing: Double
    ) {
        let baseSmoothing = clamp(
            brush.configuration.baseSmoothing,
            min: 0, max: 1)
        
        let adjustedSmoothing = map(
            clamp(smoothing, min: 0, max: 1),
            in: (0, 1),
            to: (baseSmoothing, 1))
        
        windowSize = adjustedSmoothing * maxWindowSize
        
        resampleTimeOffsets = Self
            .resampleTimeOffsets(windowSize: windowSize)
        
        windowWeights = Self.windowWeights(
            count: resampleTimeOffsets.count)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: IntermediateSampleBatch
    ) -> IntermediateSampleBatch {

        if !input.isFinalized {
            isOutputFinalized = false
        }
        
        var output: [IntermediateSample] = []

        processSamples(
            samples: input.samples,
            output: &output)
        
        if input.isFinalBatch {
            isOutputFinalized = false
            processEndOfSamples(output: &output)
        }
        
        return IntermediateSampleBatch(
            samples: output,
            finalSampleTime: input.finalSampleTime,
            isFinalBatch: input.isFinalBatch,
            isFinalized: isOutputFinalized)
    }
    
    // MARK: - Internal Logic
    
    private mutating func processSamples(
        samples: [IntermediateSample],
        output: inout [IntermediateSample]
    ) {
        for sample in samples {
            addSampleToBuffer(sample: sample)
            
            let outputSample =
                computeWeightedSampleFromBuffer(
                    windowEndTime: sample.time)
            
            output.append(outputSample)
        }
    }
    
    private mutating func processEndOfSamples(
        output: inout [IntermediateSample]
    ) {
        guard let lastSample = sampleBuffer.last
        else { return }
        
        let windowEndTargetTime =
            lastSample.time + windowSize
        
        var windowEndTime = lastSample.time
        
        while windowEndTime < windowEndTargetTime {
            windowEndTime += tailSampleInterval
            
            let outputSample =
                computeWeightedSampleFromBuffer(
                    windowEndTime: windowEndTime)
            
            output.append(outputSample)
        }
    }
    
    private mutating func addSampleToBuffer(
        sample: IntermediateSample
    ) {
        sampleBuffer.append(sample)
        
        let windowStartTime =
            sample.time - windowSize
        
        let outsideWindowCount = sampleBuffer
            .prefix { $0.time < windowStartTime }
            .count
        
        let removeCount = max(0, outsideWindowCount - 1)
        
        sampleBuffer.removeFirst(removeCount)
    }
    
    private func computeWeightedSampleFromBuffer(
        windowEndTime: TimeInterval
    ) -> IntermediateSample {
        
        let resampleTimes = resampleTimeOffsets
            .map { windowEndTime + $0 }
        
        let windowSamples =
            try! StrokeEngineSampleResampler.resample(
                samples: sampleBuffer,
                resampleTimes: resampleTimes)
        
        return Self.weightedAverageSample(
            samples: windowSamples,
            weights: windowWeights)
    }
    
    private static func weightedAverageSample(
        samples: [IntermediateSample],
        weights: [Double]
    ) -> IntermediateSample {
        
        guard !samples.isEmpty,
            samples.count == weights.count
        else {
            fatalError()
        }
        
        return try! interpolate(
            values: samples,
            weights: weights)
    }
    
    // MARK: - Setup
    
    private static func resampleTimeOffsets(
        windowSize: TimeInterval
    ) -> [TimeInterval] {
        
        if windowSize < 0.001 {
            return [0]
        }
        
        let timeCount = clamp(
            Int(windowSize / resampleInterval),
            min: minResampleCount,
            max: maxResampleCount)
        
        let times = (0 ..< timeCount).map { i in
            let c = Double(i) / Double(timeCount - 1)
            return -c * windowSize
        }
        return times.reversed()
    }
    
    private static func windowWeights(
        count: Int
    ) -> [Double] {
        (0 ..< count).map {
            windowWeight(index: $0, count: count)
        }
    }
    
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
