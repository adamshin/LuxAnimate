//
//  BrushStrokeEngine2.swift
//

import Foundation

// MARK: - Structs

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
        
        // TODO: Index?
    }
    
    struct Stamp {
        var position: Vector
        var size: Double
        var rotation: Double
        var alpha: Double
        var color: Color
        
        var offset: Vector
        var strokeDistance: Double
        
        var isFinalized: Bool
    }
    
    struct ProcessOutput {
        var brush: Brush
        var stamps: [Stamp]
    }
    
}

// MARK: - BrushStrokeEngine2

class BrushStrokeEngine2 {
    
    private let brush: Brush
    private let color: Color
    private let quickTap: Bool
    
    private let inputQueue = BrushStrokeEngineInputQueue()
    private let gapFillProcessor = BrushStrokeEngineGapFillProcessor()
    private let stampProcessor: BrushStrokeEngineStampProcessor
    
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
        
        stampProcessor = .init(color: color)
    }
    
    func update(
        addedSamples: [InputSample],
        predictedSamples: [InputSample]
    ) {
        inputQueue.handleInputUpdate(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func update(
        sampleUpdates: [InputSampleUpdate]
    ) {
        inputQueue.handleInputUpdate(
            sampleUpdates: sampleUpdates)
    }
    
    func process() -> ProcessOutput {
        let s1 = inputQueue.process()
        let s2 = gapFillProcessor.process(input: s1)
        let s3 = stampProcessor.process(input: s2)
        
        return ProcessOutput(
            brush: brush,
            stamps: s3)
    }
    
}
