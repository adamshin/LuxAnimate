//
//  TestBrushStrokeAdapter.swift
//

import Foundation

struct TestBrushStrokeAdapter {
    
    static func convert(
        stroke: BrushGestureRecognizer.Stroke,
        viewportSize: Size,
        canvasSize: Size,
        workspaceTransform: TestWorkspaceTransform
    ) -> BrushStrokeEngine.InputStroke {
        
        // Transform
        var strokeTransform = Matrix3.identity
        
        strokeTransform = Matrix3(translation: Vector(
            -viewportSize.width / 2,
            -viewportSize.height / 2))
            * strokeTransform
        
        strokeTransform =
            workspaceTransform.matrix().inverse()
            * strokeTransform
        
        strokeTransform = Matrix3(translation: Vector(
            canvasSize.width / 2,
            canvasSize.height / 2))
            * strokeTransform
        
        // Samples
        let samples = stroke.samples + stroke.predictedSamples
        
        let inputSamples = samples.map { sample in
            let position = strokeTransform * Vector(sample.position)
            
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

