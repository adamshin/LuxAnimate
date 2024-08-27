//
//  TestBrushStrokeAdapter.swift
//

import Foundation

struct TestBrushStrokeAdapter {
    
    static func convert(
        stroke: BrushGestureRecognizer.Stroke,
        workspaceViewSize: Size,
        workspaceTransform: TestWorkspaceTransform,
        layerContentSize: Size,
        layerTransform: Matrix3
    ) -> BrushStrokeEngine.InputStroke {
        
        let transform = Self.workspaceViewToLayerSpaceTransform(
            workspaceViewSize: workspaceViewSize,
            workspaceTransform: workspaceTransform,
            layerContentSize: layerContentSize,
            layerTransform: layerTransform)
        
        let samples = stroke.samples + stroke.predictedSamples
        
        let inputSamples = samples.map { sample in
            let position = transform * Vector(sample.position)
            
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
    
    private static func workspaceViewToLayerSpaceTransform(
        workspaceViewSize: Size,
        workspaceTransform: TestWorkspaceTransform,
        layerContentSize: Size,
        layerTransform: Matrix3
    ) -> Matrix3 {
        
        var t = Matrix3.identity
        
        // Transform to centered origin workspace view space
        t = Matrix3(translation: Vector(
            -workspaceViewSize.width / 2,
            -workspaceViewSize.height / 2))
            * t
        
        // Transform to scene space
        t = workspaceTransform.matrix().inverse()
            * t
        
        // Transform to layer space
        t = layerTransform.inverse()
            * t
        
        // Transform to layer content space
        t = Matrix3(translation: Vector(
            layerContentSize.width / 2,
            layerContentSize.height / 2))
            * t
        
        return t
    }
    
}
