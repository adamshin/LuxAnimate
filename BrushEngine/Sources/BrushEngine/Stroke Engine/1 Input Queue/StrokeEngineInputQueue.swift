
import Foundation
import Geometry

private let finalizationThreshold = 30

/// Manages sample input, handling added samples and updates to predicted values. Outputs one sample at a time for downstream processing.

struct StrokeEngineInputQueue {
    
    private var samples: [BrushEngine.InputSample] = []
    private var predictedSamples: [BrushEngine.InputSample] = []
    
    private var finalSampleTime: TimeInterval = 0
    
    private var isOutputFinalized = true
    
    // MARK: - Interface
    
    mutating func handleInputUpdate(
        addedSamples: [BrushEngine.InputSample],
        predictedSamples: [BrushEngine.InputSample]
    ) {
        self.samples += addedSamples
        self.predictedSamples = predictedSamples
        
        let finalizationOverflow =
            samples.count - finalizationThreshold
        
        if finalizationOverflow > 0 {
            for i in 0 ..< finalizationOverflow {
                samples[i].estimationFlags.pressure = false
                samples[i].estimationFlags.altitude = false
                samples[i].estimationFlags.azimuth = false
                samples[i].estimationFlags.roll = false
            }
        }
        
        if let finalSample =
            predictedSamples.last ?? samples.last
        {
            finalSampleTime = finalSample.time
        }
    }
    
    mutating func handleInputUpdate(
        sampleUpdates: [BrushEngine.InputSampleUpdate]
    ) {
        for u in sampleUpdates {
            samples = samples.map { s in
                guard s.updateID == u.updateID
                else { return s }
                
                return Self.applySampleUpdate(
                    sample: s,
                    update: u)
            }
        }
    }
    
    mutating func processNextSample()
    -> IntermediateSampleBatch {
        
        if let s = samples.first {
            samples.removeFirst()
            
            if s.estimationFlags.hasEstimatedValues {
                isOutputFinalized = false
            }
            
            let sample = Self.convert(inputSample: s)
            return IntermediateSampleBatch(
                samples: [sample],
                finalSampleTime: finalSampleTime,
                isFinalBatch: false,
                isFinalized: isOutputFinalized)
            
        } else if let s = predictedSamples.first {
            predictedSamples.removeFirst()
            
            let sample = Self.convert(inputSample: s)
            return IntermediateSampleBatch(
                samples: [sample],
                finalSampleTime: finalSampleTime,
                isFinalBatch: false,
                isFinalized: false)
        }
        
        return IntermediateSampleBatch(
            samples: [],
            finalSampleTime: finalSampleTime,
            isFinalBatch: true,
            isFinalized: false)
    }
    
    // MARK: - Internal Logic
    
    private static func convert(
        inputSample s: InputSample
    ) -> IntermediateSample {
        
        let azimuth = Complex(s.azimuth.x, s.azimuth.y)
        let roll = Complex(length: 1, phase: -s.roll)
        
        return IntermediateSample(
            time: s.time,
            position: s.position,
            pressure: s.pressure,
            altitude: s.altitude,
            azimuth: azimuth,
            roll: roll)
    }
    
    private static func applySampleUpdate(
        sample s: InputSample,
        update u: InputSampleUpdate
    ) -> InputSample {
        
        var s = s
        
        if let pressure = u.pressure,
            s.estimationFlags.pressure
        {
            s.pressure = pressure
            s.estimationFlags.pressure = false
        }
        if let altitude = u.altitude,
            s.estimationFlags.altitude
        {
            s.altitude = altitude
            s.estimationFlags.altitude = false
        }
        if let azimuth = u.azimuth,
            s.estimationFlags.azimuth
        {
            s.azimuth = azimuth
            s.estimationFlags.azimuth = false
        }
        if let roll = u.roll,
            s.estimationFlags.roll
        {
            s.roll = roll
            s.estimationFlags.roll = false
        }
        
        return s
    }
    
}
