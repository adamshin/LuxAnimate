
import Foundation
import Geometry

struct StrokeEngineInputQueue {
    
    static let finalizationThreshold = 30
    
    private var samples: [BrushEngine.InputSample] = []
    private var predictedSamples: [BrushEngine.InputSample] = []
    
    private var lastSampleTime: TimeInterval = 0
    
    private var isOutputFinalized = true
    
    // MARK: - Interface
    
    mutating func handleInputUpdate(
        addedSamples: [BrushEngine.InputSample],
        predictedSamples: [BrushEngine.InputSample]
    ) {
        self.samples += addedSamples
        self.predictedSamples = predictedSamples
        
        let finalizationOverflow =
            samples.count - Self.finalizationThreshold
        
        if finalizationOverflow > 0 {
            for i in 0 ..< finalizationOverflow {
                samples[i].estimationFlags.pressure = false
                samples[i].estimationFlags.altitude = false
                samples[i].estimationFlags.azimuth = false
                samples[i].estimationFlags.roll = false
            }
        }
        
        if let lastSample =
            predictedSamples.last ?? samples.last
        {
            lastSampleTime = lastSample.time
        }
        
//        print("Input queue sample count: \(samples.count)")
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
    -> StrokeEngine.ProcessorOutput {
        
        if let s = samples.first {
            samples.removeFirst()
            
            if s.estimationFlags.hasEstimatedValues {
                isOutputFinalized = false
            }
            
            let sample = Self.convert(inputSample: s)
            return StrokeEngine.ProcessorOutput(
                samples: [sample],
                strokeEndTime: lastSampleTime,
                isStrokeEnd: false,
                isFinalized: isOutputFinalized)
            
        } else if let s = predictedSamples.first {
            predictedSamples.removeFirst()
            
            let sample = Self.convert(inputSample: s)
            return StrokeEngine.ProcessorOutput(
                samples: [sample],
                strokeEndTime: lastSampleTime,
                isStrokeEnd: false,
                isFinalized: false)
        }
        
        return StrokeEngine.ProcessorOutput(
            samples: [],
            strokeEndTime: lastSampleTime,
            isStrokeEnd: true,
            isFinalized: false)
    }
    
    // MARK: - Internal Logic
    
    private static func convert(
        inputSample s: InputSample
    ) -> Sample {
        
        let azimuth = Complex(s.azimuth.x, s.azimuth.y)
        let roll = Complex(length: 1, phase: -s.roll)
        
        return Sample(
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
