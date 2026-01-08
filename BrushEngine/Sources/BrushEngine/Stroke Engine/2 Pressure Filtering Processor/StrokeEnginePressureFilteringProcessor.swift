
import Foundation

// Pressure value per second
private let maxPressureIncreaseRate: Double = 10
private let maxPressureDecreaseRate: Double = 15

/// Filters sudden jumps in pressure input by limiting the rate of change. Helps eliminate noise at stroke start and end.

struct StrokeEnginePressureFilteringProcessor {
    
    private var lastTime: TimeInterval = 0
    private var lastPressure: Double = 0
    
    mutating func process(
        input: IntermediateSampleBatch
    ) -> IntermediateSampleBatch {
        
        var output = input
        
        for i in 0 ..< output.samples.count {
            var s = output.samples[i]
            
            let dt = s.time - lastTime
            guard dt > 0 else {
                s.pressure = lastPressure
                output.samples[i] = s
                continue
            }
            
            let maxIncrease = maxPressureIncreaseRate * dt
            let maxDecrease = maxPressureDecreaseRate * dt
            
            s.pressure = clamp(
                s.pressure,
                min: lastPressure - maxDecrease,
                max: lastPressure + maxIncrease)
            output.samples[i] = s
            
            lastTime = s.time
            lastPressure = s.pressure
        }
        
        return output
    }
    
}
