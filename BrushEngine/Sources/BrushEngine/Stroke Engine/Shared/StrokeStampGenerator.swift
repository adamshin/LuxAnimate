
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
        output: inout [SpriteRenderer.Sprite]
    ) {
        let position = s.position + s.stampOffset
        let size = Size(s.stampSize, s.stampSize)
        
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
            
            let positionJitter = positionJitter(
                brush: brush,
                stampSize: s.stampSize)
            
            position += positionJitter
            
            let paddingScale: Double =
                s.stampSize < paddingSizeThreshold ?
                3 : 1
            
            let transform = Matrix3(rotation: rotation)
            
            let sprite = SpriteRenderer.Sprite(
                position: position,
                size: size,
                transform: transform,
                color: color,
                alpha: s.stampAlpha,
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
    
}
