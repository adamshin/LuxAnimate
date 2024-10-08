//
//  BrushStrokeEngine2.swift
//

import Foundation

extension BrushStrokeEngine2 {
    
    struct InputSample {
        var isPredicted: Bool
        var updateID: Int?
        
        var timeOffset: TimeInterval
        var position: Vector
        var pressure: Double
        var altitude: Double
        var azimuth: Vector
        
        var isPressureEstimated: Bool
        var isAltitudeEstimated: Bool
        var isAzimuthEstimated: Bool
        
        var hasEstimatedValues: Bool {
            isPressureEstimated ||
            isAltitudeEstimated ||
            isAzimuthEstimated
        }
        var isFinalized: Bool {
            !isPredicted && !hasEstimatedValues
        }
    }
    
    struct InputSampleUpdate {
        var updateID: Int
        
        var pressure: Double?
        var altitude: Double?
        var azimuth: Vector?
    }
    
    struct Sample {
        var timeOffset: TimeInterval
        
        var position: Vector
        var pressure: Double
        var altitude: Double
        var azimuth: Vector
        
        var isFinalized: Bool
    }
    
    struct Stamp {
        var position: Vector
        var size: Double
        var rotation: Double
        var alpha: Double
        
        var offset: Vector
        var strokeDistance: Double
        
        var isFinalized: Bool
    }
    
}

class BrushStrokeEngine2 {
    
    private let brush: Brush
    private let color: Color
    private let quickTap: Bool
    
    private let inputQueue = BrushStrokeEngineInputQueue()
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool
    ) {
        self.brush = brush
        self.color = color
        self.quickTap = quickTap
    }
    
    func update(
        addedSamples: [Int],
        predictedSamples: [Int]
    ) {
        // TODO: Put new samples in state input queue
    }
    
    func update(
        sampleUpdates: [Int]
    ) {
        // TODO: Update existing samples in state input queue
    }
    
    func process() {
        // Pull samples from input queue one by one.
        
        // Feed them through the processors.
        
        // Take a state snapshot at the last point before
        // we get unfinalized output stamps. Restart from
        // this point next time.
        
        // Collect the output. Return it.
    }
    
}
