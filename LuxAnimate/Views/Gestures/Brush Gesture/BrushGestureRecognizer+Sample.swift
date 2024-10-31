//
//  BrushGestureRecognizer+Sample.swift
//

import UIKit
import CoreGraphics

// MARK: - Sample

extension BrushGestureRecognizer {
    
    struct Sample {
        var time: TimeInterval
        var updateID: Int?
        
        var position: CGPoint
        
        var maximumPossibleForce: Double
        
        var force: Double
        var altitude: Double
        var azimuth: CGVector
        var roll: Double
        
        var estimationFlags: SampleEstimationFlags
    }
    
    struct SampleEstimationFlags {
        var force: Bool
        var altitude: Bool
        var azimuth: Bool
        var roll: Bool
    }
    
    struct SampleUpdate {
        var updateID: Int
        
        var maximumPossibleForce: Double
        
        var force: Double?
        var altitude: Double?
        var azimuth: CGVector?
        var roll: Double?
    }
    
}

// MARK: - Sample Extraction

extension BrushGestureRecognizer {
    
    static func extractSamples(
        touch: UITouch,
        event: UIEvent,
        startTimestamp: TimeInterval,
        view: UIView?
    ) -> (
        [BrushGestureRecognizer.Sample],
        [BrushGestureRecognizer.Sample]
    ) {
        let touches = event
            .coalescedTouches(for: touch) ?? []
        let predictedTouches = event
            .predictedTouches(for: touch) ?? []
        
        let samples = touches.map {
            extractSample(
                touch: $0,
                view: view,
                startTimestamp: startTimestamp)
        }
        let predictedSamples = predictedTouches.map {
            extractSample(
                touch: $0,
                view: view,
                startTimestamp: startTimestamp)
        }
        
        if BrushGestureRecognizer.Config.usePredictedTouches {
            return (samples, predictedSamples)
        } else {
            return (samples, [])
        }
    }
    
    private static func extractSample(
        touch: UITouch,
        view: UIView?,
        startTimestamp: TimeInterval
    ) -> Sample {
        
        let time = touch.timestamp - startTimestamp
        let updateID = touch.estimationUpdateIndex?.intValue
        
        let forceEstimated = touch
            .estimatedPropertiesExpectingUpdates
            .contains(.force)
        let altitudeEstimated = touch
            .estimatedPropertiesExpectingUpdates
            .contains(.altitude)
        let azimuthEstimated = touch
            .estimatedPropertiesExpectingUpdates
            .contains(.azimuth)
        let rollEstimated = touch
            .estimatedPropertiesExpectingUpdates
            .contains(.roll)
        
        return BrushGestureRecognizer.Sample(
            time: time,
            updateID: updateID,
            position: touch.preciseLocation(in: view),
            maximumPossibleForce: touch.maximumPossibleForce,
            force: touch.force,
            altitude: touch.altitudeAngle,
            azimuth: touch.azimuthUnitVector(in: view),
            roll: touch.rollAngle,
            estimationFlags: .init(
                force: forceEstimated,
                altitude: altitudeEstimated,
                azimuth: azimuthEstimated,
                roll: rollEstimated))
    }
    
    static func extractSampleUpdates(
        touches: Set<UITouch>,
        view: UIView?
    ) -> [SampleUpdate] {
        
        return touches.compactMap { touch -> SampleUpdate? in
            guard let updateID =
                touch.estimationUpdateIndex?.intValue
            else { return nil }
            
            var sampleUpdate = SampleUpdate(
                updateID: updateID,
                maximumPossibleForce: touch.maximumPossibleForce)
            
            if !touch
                .estimatedPropertiesExpectingUpdates
                .contains(.force)
            {
                sampleUpdate.force = touch.force
            }
            if !touch
                .estimatedPropertiesExpectingUpdates
                .contains(.altitude)
            {
                sampleUpdate.altitude = touch.altitudeAngle
            }
            if !touch
                .estimatedPropertiesExpectingUpdates
                .contains(.azimuth)
            {
                sampleUpdate.azimuth = touch
                    .azimuthUnitVector(in: view)
            }
            if !touch
                .estimatedPropertiesExpectingUpdates
                .contains(.roll)
            {
                sampleUpdate.roll = touch.rollAngle
            }
            
            return sampleUpdate
        }
    }
    
}
