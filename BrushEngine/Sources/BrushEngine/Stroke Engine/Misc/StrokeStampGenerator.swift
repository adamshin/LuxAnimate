
import Foundation
import Geometry
import Color
import Render

private let paddingSizeThreshold: Double = 20

struct StrokeStampGenerator {
    
    static func generate(
        sample s: StrokeSample,
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
