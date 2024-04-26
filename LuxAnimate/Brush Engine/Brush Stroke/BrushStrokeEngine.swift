//
//  BrushStrokeEngine.swift
//

import Foundation

extension BrushStrokeEngine {
    
    struct Sample {
        var timeOffset: TimeInterval
        var position: Vector
        var pressure: Double
        var altitude: Double
        var azimuth: Vector
        var isFinalized: Bool
    }
    
    struct Stamp {
        var size: Double
        var position: Vector
        var rotation: Double
        var alpha: Double
        var isFinalized: Bool
    }
    
    struct InputStroke {
        var samples: [Sample]
        var startTimestamp: TimeInterval
        var hasTouchEnded: Bool
    }
    
    struct OutputStroke {
        var brush: Brush
        var color: Color
        var stamps: [Stamp]
    }
    
}

class BrushStrokeEngine {
    
    private let brush: Brush
    private let color: Color
    
    private let inputInterpolationProcessor: BrushStrokeInputInterpolationProcessor
    private let smoothingProcessor: BrushStrokeSmoothingProcessor
    private let pressureFilteringProcessor: BrushStrokePressureFilteringProcessor
    private let stampProcessor: BrushStrokeStampProcessor
    
    private var inputStroke: InputStroke?
    private(set) var outputStroke: OutputStroke
    
    init(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothingLevel: Double
    ) {
        self.brush = brush
        self.color = color
        
        inputInterpolationProcessor = .init()
        
        smoothingProcessor = .init(
            smoothingLevel: smoothingLevel)
        
        pressureFilteringProcessor = .init()
        
        stampProcessor = .init(
            brush: brush,
            scale: scale)
        
        outputStroke = OutputStroke(
            brush: brush,
            color: color,
            stamps: [])
    }
    
    func update(inputStroke: InputStroke) {
        self.inputStroke = inputStroke
    }
    
    func process() {
        guard let inputStroke else { return }
        
        let samples1 = inputInterpolationProcessor.process(
            samples: inputStroke.samples)
        
        let samples2 = smoothingProcessor.process(
            samples: samples1)
        
        let samples3 = pressureFilteringProcessor.process(
            samples: samples2)

        let stamps = stampProcessor.process(
            samples: samples3)
        
        outputStroke.stamps = stamps
    }
    
}
