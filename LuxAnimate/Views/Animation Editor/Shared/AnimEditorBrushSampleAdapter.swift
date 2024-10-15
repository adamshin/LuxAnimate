//
//  AnimEditorBrushSampleAdapter.swift
//

import Foundation

@MainActor
struct AnimEditorBrushSampleAdapter {
    
    let transform: Matrix3
    
    init(
        workspaceViewSize: Size,
        workspaceTransform: EditorWorkspaceTransform,
        layerContentSize: Size,
        layerTransform: Matrix3
    ) {
        transform = Self.workspaceViewToLayerSpaceTransform(
            workspaceViewSize: workspaceViewSize,
            workspaceTransform: workspaceTransform,
            layerContentSize: layerContentSize,
            layerTransform: layerTransform)
    }
    
    func convert(
        sample s: BrushGestureRecognizer.Sample
    ) -> BrushEngine2.InputSample {
        
        let position = transform * Vector(s.position)
        
        let pressure = Self.pressure(
            force: s.force,
            maxForce: s.maximumPossibleForce)
        
        return BrushEngine2.InputSample(
            isPredicted: s.isPredicted,
            timeOffset: s.timeOffset,
            position: position,
            pressure: pressure,
            altitude: s.altitude,
            azimuth: s.azimuth,
            roll: s.roll,
            isPressureEstimated: s.isForceEstimated,
            isAltitudeEstimated: s.isAltitudeEstimated,
            isAzimuthEstimated: s.isAzimuthEstimated,
            isRollEstimated: s.isRollEstimated)
    }
    
    func convert(
        sampleUpdate s: BrushGestureRecognizer.SampleUpdate
    ) -> BrushEngine2.InputSampleUpdate {
        
        let pressure = s.force.map {
            Self.pressure(
                force: $0,
                maxForce: s.maximumPossibleForce)
        }
        
        return BrushEngine2.InputSampleUpdate(
            updateID: s.updateID,
            pressure: pressure,
            altitude: s.altitude,
            azimuth: s.azimuth,
            roll: s.roll)
    }
    
    private static func pressure(
        force: Double,
        maxForce: Double
    ) -> Double {
        
        let normalizedForce: Double
        if maxForce < 0.001 {
            normalizedForce = 0
        } else {
            normalizedForce = force / maxForce
        }
        
        return clamp(
            normalizedForce,
            min: 0, max: 1)
    }
    
    private static func workspaceViewToLayerSpaceTransform(
        workspaceViewSize: Size,
        workspaceTransform: EditorWorkspaceTransform,
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
