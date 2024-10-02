//
//  BrushStrokeEngineInputQueue.swift
//

import Foundation

class BrushStrokeEngineInputQueue {
    
    static let maxInputSampleCount = 100
    
    private var inputSamples:
        [BrushStrokeEngine2.InputSample] = []
    
    private var predictedInputSamples:
        [BrushStrokeEngine2.InputSample] = []
    
    func handleInputUpdate(
        addedSamples: [BrushStrokeEngine2.InputSample],
        predictedSamples: [BrushStrokeEngine2.InputSample]
    ) {
        self.inputSamples += addedSamples
        self.predictedInputSamples = predictedSamples
    }
    
    func handleInputUpdate(
        sampleUpdates: [BrushStrokeEngine2.InputSampleUpdate]
    ) {
        for update in sampleUpdates {
            if let index = inputSamples.firstIndex(
                where: { $0.updateID == update.updateID })
            {
                var sample = inputSamples[index]
                
                if let pressure = update.pressure {
                    sample.pressure = pressure
                    sample.isPressureEstimated = false
                }
                if let altitude = update.altitude {
                    sample.altitude = altitude
                    sample.isAltitudeEstimated = false
                }
                if let pressure = update.pressure {
                    sample.pressure = pressure
                    sample.isPressureEstimated = false
                }
                
                inputSamples[index] = sample
            }
        }
    }
    
    func process()
    -> BrushStrokeEngine2.ProcessorOutput {
        
        var output = BrushStrokeEngine2.ProcessorOutput()
        
        let finalizedPrefixCount = inputSamples
            .prefix { $0.isFinalized }.count
        
        let prefixCount = max(
            finalizedPrefixCount,
            inputSamples.count - Self.maxInputSampleCount)
        
        output.finalizedSamples = inputSamples
            .prefix(prefixCount)
            .map { Self.convert(inputSample: $0) }
        
        inputSamples.removeFirst(prefixCount)
        
        output.unfinalizedSamples = inputSamples
            .map { Self.convert(inputSample: $0) }
        
        output.unfinalizedSamples += predictedInputSamples
            .map { Self.convert(inputSample: $0) }
        
        return output
    }
    
    private static func convert(
        inputSample s: BrushStrokeEngine2.InputSample
    ) -> BrushStrokeEngine2.Sample {
        
        BrushStrokeEngine2.Sample(
            timeOffset: s.timeOffset,
            position: s.position,
            pressure: s.pressure,
            altitude: s.altitude,
            azimuth: s.azimuth)
    }
    
}
