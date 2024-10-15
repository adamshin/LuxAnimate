//
//  BrushGestureRecognizer+Sample.swift
//

import UIKit

// MARK: - Sample

extension BrushGestureRecognizer {
    
    @MainActor
    struct Sample {
        var timeOffset: TimeInterval
        var isPredicted: Bool
        var updateID: Int?
        
        var position: CGPoint
        
        var maximumPossibleForce: Double
        
        var force: Double
        var altitude: Double
        var azimuth: Double
        var roll: Double
        
        var isForceEstimated: Bool
        var isAltitudeEstimated: Bool
        var isAzimuthEstimated: Bool
        var isRollEstimated: Bool
    }
    
    struct SampleUpdate {
        var updateID: Int
        
        var maximumPossibleForce: Double
        
        var force: Double?
        var altitude: Double?
        var azimuth: Double?
        var roll: Double?
    }
    
}

// MARK: - Sample Extraction

extension BrushGestureRecognizer {
    
    static func extractSamples(
        touch: UITouch,
        event: UIEvent,
        startTime: TimeInterval,
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
                startTime: startTime,
                isPredicted: false)
        }
        let predictedSamples = predictedTouches.map {
            extractSample(
                touch: $0,
                view: view,
                startTime: startTime,
                isPredicted: true)
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
        startTime: TimeInterval,
        isPredicted: Bool
    ) -> Sample {
        
        let timeOffset = touch.timestamp - startTime
        let updateID = touch.estimationUpdateIndex?.intValue
        
        return BrushGestureRecognizer.Sample(
            timeOffset: timeOffset,
            isPredicted: isPredicted,
            updateID: updateID,
            position: touch.preciseLocation(in: view),
            maximumPossibleForce: touch.maximumPossibleForce,
            force: touch.force,
            altitude: touch.altitudeAngle,
            azimuth: touch.azimuthAngle(in: view),
            roll: touch.rollAngle,
            isForceEstimated: touch
                .estimatedPropertiesExpectingUpdates
                .contains(.force),
            isAltitudeEstimated: touch
                .estimatedPropertiesExpectingUpdates
                .contains(.altitude),
            isAzimuthEstimated: touch
                .estimatedPropertiesExpectingUpdates
                .contains(.azimuth),
            isRollEstimated: touch
                .estimatedPropertiesExpectingUpdates
                .contains(.roll))
    }
    
    static func extractSampleUpdates(
        touches: Set<UITouch>,
        view: UIView?
    ) -> [SampleUpdate] {
        
        return touches.compactMap { touch in
            guard let updateID =
                touch.estimationUpdateIndex?.intValue
            else { return nil }
            
            var sampleUpdate = SampleUpdate(
                updateID: updateID,
                maximumPossibleForce: touch.maximumPossibleForce)
            
            if !touch.estimatedPropertiesExpectingUpdates
                .contains(.force)
            {
                sampleUpdate.force = touch.force
            }
            if !touch.estimatedPropertiesExpectingUpdates
                .contains(.altitude)
            {
                sampleUpdate.altitude = touch.altitudeAngle
            }
            if !touch.estimatedPropertiesExpectingUpdates
                .contains(.azimuth)
            {
                sampleUpdate.azimuth = touch.azimuthAngle(in: view)
            }
            if !touch.estimatedPropertiesExpectingUpdates
                .contains(.roll)
            {
                sampleUpdate.roll = touch.rollAngle
            }
            
            return sampleUpdate
        }
    }
    
}
