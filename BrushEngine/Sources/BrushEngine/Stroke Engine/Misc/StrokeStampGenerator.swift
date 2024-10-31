
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
            // Normalize and add 90 degs counterclockwise.
            // This points the top of the stamp image
            // towards the tip of the pencil.
            let n = s.stampRotation.normalized()
            rotation = n * -.i
        }
        
        let paddingScale: Double =
            s.stampSize < paddingSizeThreshold ?
            3 : 1
        
        let sprite = SpriteRenderer.Sprite(
            position: position,
            size: size,
            rotation: rotation,
            color: color,
            alpha: s.stampAlpha,
            paddingScale: paddingScale)
        
        output.append(sprite)
    }
    
}
