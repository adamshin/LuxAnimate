//
//  BrushGestureRecognizerStroke.swift
//

import UIKit

extension BrushGestureRecognizer {
    
    struct Stroke {
        var touch: UITouch
        
        var startTimestamp: TimeInterval
        var hasTouchEnded: Bool
        
        var samples: [Sample]
        var predictedSamples: [Sample]
        
        var estimationUpdateIndexesToSampleIndexes: [Int: Int]
    }
    
    struct Sample {
        var timeOffset: TimeInterval
        var isPredicted: Bool
        
        var position: CGPoint
        
        var maximumPossibleForce: Double
        
        var force: Double
        var altitude: Double
        var azimuth: CGVector
        
        var isForceEstimated: Bool
        var isAltitudeEstimated: Bool
        var isAzimuthEstimated: Bool
        
        var estimationUpdateIndex: Int?
        
        var hasEstimatedValues: Bool {
            isForceEstimated ||
            isAltitudeEstimated ||
            isAzimuthEstimated
        }
    }
    
}

extension BrushGestureRecognizer.Stroke {
    
    init(touch: UITouch) {
        self.touch = touch
        self.startTimestamp = touch.timestamp
        self.hasTouchEnded = false
        self.samples = []
        self.predictedSamples = []
        self.estimationUpdateIndexesToSampleIndexes = [:]
    }
    
    mutating func update(
        event: UIEvent, 
        view: UIView?
    ) {
        for (key, value) in estimationUpdateIndexesToSampleIndexes {
            var sample = samples[value]
            
            let sampleTimestamp = startTimestamp + sample.timeOffset
            let sampleAge = event.timestamp - sampleTimestamp
                                         
            let ageThreshold = BrushStrokeGestureConfig
                .estimateFinalizationDelay
            
            if sample.hasEstimatedValues, sampleAge > ageThreshold {
                sample.isForceEstimated = false
                sample.isAltitudeEstimated = false
                sample.isAzimuthEstimated = false
                
                samples[value] = sample
                estimationUpdateIndexesToSampleIndexes[key] = nil
            }
        }
        
        let (newSamples, newPredictedSamples) = extractSamples(
            touch: touch,
            event: event,
            view: view)
        
        let oldSampleCount = samples.count
        
        samples += newSamples
        predictedSamples = newPredictedSamples
        
        let newSampleCount = samples.count
        
        for index in oldSampleCount ..< newSampleCount {
            let sample = samples[index]
            if let estimationUpdateIndex = sample.estimationUpdateIndex {
                estimationUpdateIndexesToSampleIndexes[estimationUpdateIndex] = index
            }
        }
    }
    
    mutating func updateEstimated(
        touches: Set<UITouch>, 
        view: UIView?
    ) {
        for touch in touches {
            guard let estimationUpdateIndex = touch.estimationUpdateIndex?.intValue
            else { continue }
            
            guard let sampleIndex = estimationUpdateIndexesToSampleIndexes[estimationUpdateIndex]
            else { continue }
            
            var sample = samples[sampleIndex]
            
            if !touch.estimatedPropertiesExpectingUpdates.contains(.force) {
                sample.force = touch.force
                sample.isForceEstimated = false
            }
            if !touch.estimatedPropertiesExpectingUpdates.contains(.altitude) {
                sample.altitude = touch.altitudeAngle
                sample.isAltitudeEstimated = false
            }
            if !touch.estimatedPropertiesExpectingUpdates.contains(.azimuth) {
                sample.azimuth = touch.azimuthUnitVector(in: view)
                sample.isAzimuthEstimated = false
            }
            samples[sampleIndex] = sample
            
            if !sample.hasEstimatedValues {
                estimationUpdateIndexesToSampleIndexes[estimationUpdateIndex] = nil
            }
        }
    }
    
    private func extractSamples(
        touch: UITouch,
        event: UIEvent,
        view: UIView?
    ) -> ([BrushGestureRecognizer.Sample], [BrushGestureRecognizer.Sample]) {
        
        let touches = event.coalescedTouches(for: touch) ?? []
        let predictedTouches = event.predictedTouches(for: touch) ?? []
        
        let samples = touches.map {
            extractSample(touch: $0, view: view, isPredicted: false)
        }
        let predictedSamples = predictedTouches.map {
            extractSample(touch: $0, view: view, isPredicted: true)
        }
        
        if BrushStrokeGestureConfig.usePredictedTouches {
            return (samples, predictedSamples)
        } else {
            return (samples, [])
        }
    }
    
    private func extractSample(
        touch: UITouch,
        view: UIView?,
        isPredicted: Bool
    ) -> BrushGestureRecognizer.Sample {
        
        let timeOffset = touch.timestamp - startTimestamp
        
        return BrushGestureRecognizer.Sample(
            timeOffset: timeOffset,
            isPredicted: isPredicted,
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
                .contains(.azimuth),
            estimationUpdateIndex: touch
                .estimationUpdateIndex
                .map { Int(truncating: $0) })
    }
    
}
