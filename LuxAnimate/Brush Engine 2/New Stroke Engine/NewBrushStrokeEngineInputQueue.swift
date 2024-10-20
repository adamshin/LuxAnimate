//
//  NewBrushStrokeEngineInputQueue.swift
//

import Foundation

struct NewBrushStrokeEngineInputQueue {
    
    static let finalizationThreshold = 30
    
    private var samples:
        [BrushEngine2.InputSample] = []
    
    private var predictedSamples:
        [BrushEngine2.InputSample] = []
    
    // MARK: - Interface
    
    mutating func handleInputUpdate(
        addedSamples: [BrushEngine2.InputSample],
        predictedSamples: [BrushEngine2.InputSample]
    ) {
        self.samples += addedSamples
        self.predictedSamples = predictedSamples
        
        let finalizationOverflow =
            samples.count -
            Self.finalizationThreshold
        
        if finalizationOverflow > 0 {
            for i in 0 ..< finalizationOverflow {
                samples[i].isPressureEstimated = false
                samples[i].isAltitudeEstimated = false
                samples[i].isAzimuthEstimated = false
                samples[i].isRollEstimated = false
            }
        }
    }
    
    mutating func handleInputUpdate(
        sampleUpdates: [BrushEngine2.InputSampleUpdate]
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
    
    mutating func popNextSample() -> BrushEngine2.Sample? {
        if let s = samples.first {
            samples.removeFirst()
            
            let isFinalized = !s.hasEstimatedValues
            
            let isLastSample =
                samples.isEmpty &&
                predictedSamples.isEmpty
            
            return Self.convert(
                inputSample: s,
                isFinalized: isFinalized,
                isLastSample: isLastSample)
            
        } else if let s = predictedSamples.first {
            predictedSamples.removeFirst()
            
            let isLastSample = predictedSamples.isEmpty
            
            return Self.convert(
                inputSample: s,
                isFinalized: false,
                isLastSample: isLastSample)
        }
        
        return nil
    }
    
    // MARK: - Internal Logic
    
    private static func convert(
        inputSample s: BrushEngine2.InputSample,
        isFinalized: Bool,
        isLastSample: Bool
    ) -> BrushEngine2.Sample {
        
        BrushEngine2.Sample(
            timeOffset: s.timeOffset,
            position: s.position,
            pressure: s.pressure,
            altitude: s.altitude,
            azimuth: s.azimuth,
            roll: s.roll,
            isFinalized: isFinalized,
            isLastSample: isLastSample)
    }
    
    private static func applySampleUpdate(
        sample s: BrushEngine2.InputSample,
        update u: BrushEngine2.InputSampleUpdate
    ) -> BrushEngine2.InputSample {
        
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
