
import Foundation

// Pressure value per second
private let maxPressureIncreaseRate: Double = 10
private let maxPressureDecreaseRate: Double = 15

/// Filters sudden jumps in pressure input by limiting the rate of change. Helps eliminate noise at stroke start and end.

struct StrokeEnginePressureFilteringProcessor {
    
    private var lastTime: TimeInterval = 0
    private var lastPressure: Double = 0
    
    private var isOutputFinalized = true
    
    mutating func process(
        input: IntermediateSampleBatch
    ) -> IntermediateSampleBatch {
        
        var output: [IntermediateSample] = []
        
        if !input.isFinalized {
            isOutputFinalized = false
        }
        
        for sample in input.samples {
            let outputSample = processSample(sample)
            output.append(outputSample)
        }
        
        return IntermediateSampleBatch(
            samples: output,
            finalSampleTime: input.finalSampleTime,
            isFinalBatch: input.isFinalBatch,
            isFinalized: isOutputFinalized)
    }
    
    private mutating func processSample(
        _ sample: IntermediateSample
    ) -> IntermediateSample {
        
        var s = sample
        
        let dt = s.time - lastTime
        guard dt > 0 else {
            s.pressure = lastPressure
            return s
        }
        
        let maxIncrease = maxPressureIncreaseRate * dt
        let maxDecrease = maxPressureDecreaseRate * dt
        
        s.pressure = clamp(
            s.pressure,
            min: lastPressure - maxDecrease,
            max: lastPressure + maxIncrease)
        
        lastTime = s.time
        lastPressure = s.pressure
        
        return s
    }
    
}
