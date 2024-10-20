//
//  BrushStrokeEngineInputQueue.swift
//

import Foundation

class BrushStrokeEngineInputQueue {
    
    static let maxInputSampleCount = 30
    
    private var inputSamples:
        [BrushEngine2.InputSample] = []
    
    private var predictedInputSamples:
        [BrushEngine2.InputSample] = []
    
    func handleInputUpdate(
        addedSamples: [BrushEngine2.InputSample],
        predictedSamples: [BrushEngine2.InputSample]
    ) {
        self.inputSamples += addedSamples
        self.predictedInputSamples = predictedSamples
    }
    
    func handleInputUpdate(
        sampleUpdates: [BrushEngine2.InputSampleUpdate]
    ) {
        for u in sampleUpdates {
            inputSamples = inputSamples.map { s in
                guard s.updateID == u.updateID
                else { return s }
                
                var s = s
                
                if let pressure = u.pressure {
                    s.pressure = pressure
                    s.isPressureEstimated = false
                }
                if let altitude = u.altitude {
                    s.altitude = altitude
                    s.isAltitudeEstimated = false
                }
                if let azimuth = u.azimuth {
                    s.azimuth = azimuth
                    s.isAzimuthEstimated = false
                }
                if let roll = u.roll {
                    s.roll = roll
                    s.isRollEstimated = false
                }
                
                return s
            }
        }
    }
    
    func process() -> [BrushEngine2.Sample] {
        var output: [BrushEngine2.Sample] = []
        
        let finalizedPrefixCount = inputSamples
            .prefix { !$0.hasEstimatedValues }
            .count
        
        let prefixCount = max(
            finalizedPrefixCount,
            inputSamples.count - Self.maxInputSampleCount)
        
        output += inputSamples
            .prefix(prefixCount)
            .map {
                Self.convert(
                    inputSample: $0,
                    isFinalized: true)
            }
        
        inputSamples.removeFirst(prefixCount)
        
        output += inputSamples
            .map {
                Self.convert(
                    inputSample: $0,
                    isFinalized: false)
            }
        
        output += predictedInputSamples
            .map {
                Self.convert(
                    inputSample: $0,
                    isFinalized: false)
            }
        
        return output
    }
    
    private static func convert(
        inputSample s: BrushEngine2.InputSample,
        isFinalized: Bool
    ) -> BrushEngine2.Sample {
        
        BrushEngine2.Sample(
            timeOffset: s.timeOffset,
            position: s.position,
            pressure: s.pressure,
            altitude: s.altitude,
            azimuth: s.azimuth,
            roll: s.roll,
            isFinalized: isFinalized,
            isLastSample: false)
    }
    
}
