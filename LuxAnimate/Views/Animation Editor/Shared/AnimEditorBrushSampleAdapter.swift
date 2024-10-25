//
//  AnimEditorBrushSampleAdapter.swift
//

import Foundation
import Geometry

private let fingerPressure = 0.2

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
    ) -> BrushEngine.InputSample {
        
        let position = transform * Vector(s.position)
        
        let pressure = Self.pressure(
            force: s.force,
            maxForce: s.maximumPossibleForce)
        
        return BrushEngine.InputSample(
            updateID: s.updateID,
            time: s.time,
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
    ) -> BrushEngine.InputSampleUpdate {
        
        let pressure = s.force.map {
            Self.pressure(
                force: $0,
                maxForce: s.maximumPossibleForce)
        }
        
        return BrushEngine.InputSampleUpdate(
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
            normalizedForce = fingerPressure
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
