
import Foundation

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
                samples[i].isPressureEstimated = false
                samples[i].isAltitudeEstimated = false
                samples[i].isAzimuthEstimated = false
                samples[i].isRollEstimated = false
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
            
            if s.hasEstimatedValues {
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
        
        Sample(
            time: s.time,
            position: s.position,
            pressure: s.pressure,
            altitude: s.altitude,
            azimuth: s.azimuth,
            roll: s.roll)
    }
    
    private static func applySampleUpdate(
        sample s: InputSample,
        update u: InputSampleUpdate
    ) -> InputSample {
        
        var s = s
        
        if let pressure = u.pressure,
            s.isPressureEstimated
        {
            s.pressure = pressure
            s.isPressureEstimated = false
        }
        if let altitude = u.altitude,
            s.isAltitudeEstimated
        {
            s.altitude = altitude
            s.isAltitudeEstimated = false
        }
        if let azimuth = u.azimuth,
            s.isAzimuthEstimated
        {
            s.azimuth = azimuth
            s.isAzimuthEstimated = false
        }
        if let roll = u.roll,
            s.isRollEstimated
        {
            s.roll = roll
            s.isRollEstimated = false
        }
        
        return s
    }
    
}
