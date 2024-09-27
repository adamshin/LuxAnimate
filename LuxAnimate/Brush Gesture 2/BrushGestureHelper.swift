//
//  BrushGestureHelper.swift
//

import UIKit

@MainActor
struct BrushGestureHelper {
    
    static func extractSamples(
        touch: UITouch,
        event: UIEvent,
        startTime: TimeInterval,
        view: UIView?
    ) -> (
        [BrushGestureRecognizer2.Sample],
        [BrushGestureRecognizer2.Sample]
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
        
        if BrushGestureRecognizer2.Config.usePredictedTouches {
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
    ) -> BrushGestureRecognizer2.Sample {
        
        let timeOffset = touch.timestamp - startTime
        
        let updateID = touch.estimationUpdateIndex?.intValue
        
        return BrushGestureRecognizer2.Sample(
            timeOffset: timeOffset,
            isPredicted: isPredicted,
            updateID: updateID,
            position: touch.preciseLocation(in: view),
            maximumPossibleForce: touch.maximumPossibleForce,
            force: touch.force,
            altitude: touch.altitudeAngle,
            azimuth: touch.azimuthUnitVector(in: view),
            isForceEstimated: touch
                .estimatedPropertiesExpectingUpdates
                .contains(.force),
            isAltitudeEstimated: touch
                .estimatedPropertiesExpectingUpdates
                .contains(.altitude),
            isAzimuthEstimated: touch
                .estimatedPropertiesExpectingUpdates
                .contains(.azimuth))
    }
    
    static func extractSampleUpdates(
        touches: Set<UITouch>,
        view: UIView?
    ) -> [BrushGestureRecognizer2.SampleUpdate] {
        
        return touches.compactMap { touch in
            guard let updateID =
                touch.estimationUpdateIndex?.intValue
            else { return nil }
            
            var sampleUpdate = BrushGestureRecognizer2
                .SampleUpdate(updateID: updateID)
            
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
            
            return sampleUpdate
        }
    }
    
}
