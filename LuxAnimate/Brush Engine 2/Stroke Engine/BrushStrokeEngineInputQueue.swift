//
//  BrushStrokeEngineInputQueue.swift
//

import Foundation

private let maxInputSampleCount = 100

class BrushStrokeEngineInputQueue {
    
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
        
        var finalizedSamples: [BrushStrokeEngine2.Sample] = []
        var unfinalizedSamples: [BrushStrokeEngine2.Sample] = []
        
        let finalizedPrefixCount = inputSamples
            .prefix { $0.isFinalized }.count
        
        let prefixCount = min(
            finalizedPrefixCount,
            finalizedSamples.count - maxInputSampleCount)
        
        finalizedSamples = inputSamples.prefix(prefixCount).map {
            Self.convert(inputSample: $0, isFinalized: true)
        }
        
        inputSamples.removeFirst(prefixCount)
        
        unfinalizedSamples = inputSamples.map {
            Self.convert(inputSample: $0, isFinalized: false)
        }
        unfinalizedSamples += predictedInputSamples.map {
            Self.convert(inputSample: $0, isFinalized: false)
        }
        
        return BrushStrokeEngine2.ProcessorOutput(
            finalizedSamples: finalizedSamples,
            unfinalizedSamples: unfinalizedSamples)
    }
    
    private static func convert(
        inputSample s: BrushStrokeEngine2.InputSample,
        isFinalized: Bool
    ) -> BrushStrokeEngine2.Sample {
        
        BrushStrokeEngine2.Sample(
            timeOffset: s.timeOffset,
            position: s.position,
            pressure: s.pressure,
            altitude: s.altitude,
            azimuth: s.azimuth,
            isFinalized: isFinalized)
    }
    
}
