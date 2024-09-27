//
//  BrushEngineGestureAdapter.swift
//

import Foundation

/*
@MainActor
struct BrushEngineGestureAdapter {
    
    static func convert(
        _ stroke: BrushGestureRecognizer.Stroke
    ) -> BrushStrokeEngine.InputStroke {
        
        let samples = stroke.samples + stroke.predictedSamples
        
        let inputSamples = samples.map { sample in
            let position = Vector(sample.position)
            
            let normalizedForce: Double
            if sample.maximumPossibleForce < 0.001 {
                normalizedForce = 0
            } else {
                normalizedForce = sample.force / 
                    sample.maximumPossibleForce
            }
            
            let pressure = clamp(
                normalizedForce, min: 0, max: 1)
            
            let azimuth = Vector(
                sample.azimuth.dx,
                sample.azimuth.dy)
            
            let isFinalized = 
                !sample.isPredicted &&
                !sample.hasEstimatedValues
            
            return BrushStrokeEngine.Sample(
                timeOffset: sample.timeOffset,
                position: position,
                pressure: pressure,
                altitude: sample.altitude,
                azimuth: azimuth,
                isFinalized: isFinalized)
        }
        return BrushStrokeEngine.InputStroke(
            samples: inputSamples,
            startTimestamp: stroke.startTimestamp,
            hasTouchEnded: stroke.hasTouchEnded)
    }
    
}
*/
