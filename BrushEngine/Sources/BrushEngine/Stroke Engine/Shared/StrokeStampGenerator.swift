
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
        
        let paddingScale: Double =
            s.stampSize < paddingSizeThreshold ?
            3 : 1
        
        let sprite = SpriteRenderer.Sprite(
            position: position,
            size: Size(s.stampSize, s.stampSize),
            rotation: s.stampRotation,
            color: color,
            alpha: s.stampAlpha,
            paddingScale: paddingScale)
        
        output.append(sprite)
    }
    
}
