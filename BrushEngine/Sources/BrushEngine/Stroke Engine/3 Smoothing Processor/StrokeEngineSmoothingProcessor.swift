
import Foundation

private let maxWindowSize: TimeInterval = 0.4

private let resampleInterval: TimeInterval = 1/240
private let minResampleCount = 10
private let maxResampleCount = 100

private let tailSampleInterval: TimeInterval = 1/60

extension StrokeEngineSmoothingProcessor {
    
    struct Config {
        var windowSize: TimeInterval
        var resampleTimeOffsets: [Double]
        var windowWeights: [Double]
    }
    
    struct State {
        var sampleBuffer: [IntermediateSample] = []
        var isOutputFinalized = true
    }
    
}

struct StrokeEngineSmoothingProcessor {
    
    private let config: Config
    private var state = State()
    
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
        
        let windowSize = adjustedSmoothing * maxWindowSize
        
        let resampleTimeOffsets = Self
            .resampleTimeOffsets(windowSize: windowSize)
        
        let windowWeights = Self.windowWeights(
            count: resampleTimeOffsets.count)
        
        config = Config(
            windowSize: windowSize,
            resampleTimeOffsets: resampleTimeOffsets,
            windowWeights: windowWeights)
    }
    
    // MARK: - Interface
    
    mutating func process(
        input: IntermediateSampleBatch
    ) -> IntermediateSampleBatch {

        if !input.isFinalized {
            state.isOutputFinalized = false
        }
        
        var output: [IntermediateSample] = []

        Self.processSamples(
            samples: input.samples,
            config: config,
            state: &state,
            output: &output)
        
        if input.isFinalBatch {
            state.isOutputFinalized = false
            
            Self.processEndOfSamples(
                config: config,
                state: &state,
                output: &output)
        }
        
        return IntermediateSampleBatch(
            samples: output,
            finalSampleTime: input.finalSampleTime,
            isFinalBatch: input.isFinalBatch,
            isFinalized: state.isOutputFinalized)
    }
    
    // MARK: - Internal Logic
    
    private static func processSamples(
        samples: [IntermediateSample],
        config: Config,
        state: inout State,
        output: inout [IntermediateSample]
    ) {
        for sample in samples {
            addSampleToBuffer(
                sample: sample,
                config: config,
                sampleBuffer: &state.sampleBuffer)
            
            let newSample = Self.sample(
                config: config,
                windowEndTime: sample.time,
                sampleBuffer: state.sampleBuffer)
            
            output.append(newSample)
        }
    }
    
    private static func processEndOfSamples(
        config: Config,
        state: inout State,
        output: inout [IntermediateSample]
    ) {
        guard let lastSample = state.sampleBuffer.last
        else { return }
        
        let windowEndTargetTime =
            lastSample.time + config.windowSize
        
        var windowEndTime = lastSample.time
        
        while windowEndTime < windowEndTargetTime {
            windowEndTime += tailSampleInterval
            
            let newSample = Self.sample(
                config: config,
                windowEndTime: windowEndTime,
                sampleBuffer: state.sampleBuffer)
            
            output.append(newSample)
        }
    }
    
    private static func addSampleToBuffer(
        sample: IntermediateSample,
        config: Config,
        sampleBuffer: inout [IntermediateSample]
    ) {
        sampleBuffer.append(sample)
        
        let windowStartTime =
            sample.time - config.windowSize
        
        let outsideWindowCount = sampleBuffer
            .prefix { $0.time < windowStartTime }
            .count
        
        let removeCount = max(0, outsideWindowCount - 1)
        
        sampleBuffer.removeFirst(removeCount)
    }
    
    private static func sample(
        config: Config,
        windowEndTime: TimeInterval,
        sampleBuffer: [IntermediateSample]
    ) -> IntermediateSample {
        
        let resampleTimes = config
            .resampleTimeOffsets
            .map { windowEndTime + $0 }
        
        let windowSamples =
            try! StrokeEngineSampleResampler.resample(
                samples: sampleBuffer,
                resampleTimes: resampleTimes)
        
        return weightedAverageSample(
            samples: windowSamples,
            weights: config.windowWeights)
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
