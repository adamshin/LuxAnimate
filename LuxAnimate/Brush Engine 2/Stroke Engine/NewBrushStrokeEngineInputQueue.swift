//
//  NewBrushStrokeEngineInputQueue.swift
//

import Foundation

struct NewBrushStrokeEngineInputQueue {
    
    static let finalizationThreshold = 30
    
    private var samples: [BrushEngine2.InputSample] = []
    private var predictedSamples: [BrushEngine2.InputSample] = []
    
    private var lastSampleTimeOffset: TimeInterval = 0
    
    private var isOutputFinalized = true
    
    // MARK: - Interface
    
    mutating func handleInputUpdate(
        addedSamples: [BrushEngine2.InputSample],
        predictedSamples: [BrushEngine2.InputSample]
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
            lastSampleTimeOffset = lastSample.timeOffset
        }
        
//        print("Input queue sample count: \(samples.count)")
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
    
    mutating func processNextSample()
    -> NewBrushStrokeEngine.ProcessorOutput {
        
        if let s = samples.first {
            samples.removeFirst()
            
            if s.hasEstimatedValues {
                isOutputFinalized = false
            }
            
            let sample = Self.convert(inputSample: s)
            return NewBrushStrokeEngine.ProcessorOutput(
                samples: [sample],
                isFinalized: isOutputFinalized,
                isStrokeEnd: false,
                strokeEndTimeOffset: lastSampleTimeOffset)
            
        } else if let s = predictedSamples.first {
            predictedSamples.removeFirst()
            
            let sample = Self.convert(inputSample: s)
            return NewBrushStrokeEngine.ProcessorOutput(
                samples: [sample],
                isFinalized: false,
                isStrokeEnd: false,
                strokeEndTimeOffset: lastSampleTimeOffset)
        }
        
        return NewBrushStrokeEngine.ProcessorOutput(
            samples: [],
            isFinalized: false,
            isStrokeEnd: true,
            strokeEndTimeOffset: lastSampleTimeOffset)
    }
    
    // MARK: - Internal Logic
    
    private static func convert(
        inputSample s: BrushEngine2.InputSample
    ) -> BrushEngine2.Sample {
        
        BrushEngine2.Sample(
            timeOffset: s.timeOffset,
            position: s.position,
            pressure: s.pressure,
            altitude: s.altitude,
            azimuth: s.azimuth,
            roll: s.roll)
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
