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
        
        var offset: Vector
        var strokeDistance: Double
        
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
    private let quickTap: Bool
    
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
        quickTap: Bool,
        smoothing: Double
    ) {
        self.brush = brush
        self.color = color
        self.quickTap = quickTap
        
        inputInterpolationProcessor = .init()
        
        smoothingProcessor = .init(
            brush: brush,
            smoothing: smoothing)
        
        pressureFilteringProcessor = .init()
        
        stampProcessor = .init(
            brush: brush,
            scale: scale,
            ignoreTaper: quickTap)
        
        outputStroke = OutputStroke(
            brush: brush,
            color: color,
            stamps: [])
    }
    
    func update(inputStroke: InputStroke) {
        self.inputStroke = inputStroke
    }
    
    func processInput() {
        guard let inputStroke else { return }
        
        var samples = inputStroke.samples
        
        samples = inputInterpolationProcessor
            .process(samples: samples)
        
        samples = pressureFilteringProcessor
            .process(samples: samples)
        
        samples = smoothingProcessor
            .process(samples: samples)
        
        let stamps = stampProcessor
            .process(samples: samples)
        
        outputStroke.stamps = stamps
    }
    
}
