
import Foundation
import Geometry
import Color
import Render

private let minStampCount = 1
private let maxStampCount = 16

private let paddingSizeThreshold: Double = 20

struct StrokeStampGenerator {
    
    private let unitCircleRandomPointGenerator
        = UnitCircleRandomPointGenerator()
    
    private var rng: SplitMixRandomNumberGenerator
    
    init() {
        let seed = UInt64.random(
            in: UInt64.min ... UInt64.max)
        
        rng = SplitMixRandomNumberGenerator(
            seed: seed)
    }
    
    mutating func generate(
        sample s: StrokeSample,
        brush: Brush,
        color: Color,
        output: inout [BrushStampRenderer.Sprite]
    ) {
        let position = s.position + s.stampOffset
        
        let rotation: Complex
        if s.stampRotation.isZero {
            rotation = .one
        } else {
            rotation = s.stampRotation.normalized()
        }
        
        let stampCount = clamp(
            brush.configuration.stampCount,
            min: minStampCount,
            max: maxStampCount)
        
        for _ in 0 ..< stampCount {
            var position = position
            var size = s.stampSize
            var alpha = s.stampAlpha
            
            let positionJitter = positionJitter(
                brush: brush,
                stampSize: s.stampSize)
            position += positionJitter
            
            let rotationJitter = rotationJitter(
                brush: brush)
            
            size = size
                * (1 - Double.random(in: 0 ..< 1) * brush.configuration.stampSizeJitter)
            
            alpha = alpha
                * (1 - Double.random(in: 0 ..< 1) * brush.configuration.stampAlphaJitter)
            
            let paddingScale: Double =
                s.stampSize < paddingSizeThreshold ?
                3 : 1
            
            var transform = Matrix3(rotation: rotation)
            transform = Matrix3(rotation: rotationJitter) * transform
            
            let sprite = BrushStampRenderer.Sprite(
                position: position,
                size: Size(size, size),
                transform: transform,
                color: color,
                alpha: alpha,
                paddingScale: paddingScale)
            
            output.append(sprite)
        }
    }
    
    private mutating func positionJitter(
        brush: Brush,
        stampSize: Double
    ) -> Vector {
        
        let point = unitCircleRandomPointGenerator
            .point(using: &rng)
        
        return point
            * brush.configuration.stampPositionJitter
            * stampSize
    }
    
    private mutating func rotationJitter(
        brush: Brush
    ) -> Double {
        
        let rotation = Double.random(
            in: -.pi ... .pi,
            using: &rng)
        
        return rotation
            * brush.configuration.stampRotationJitter
    }
    
}
