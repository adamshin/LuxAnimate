
import Foundation
import Geometry
import Color

struct StrokeStampGenerator {
    
    static func strokeStamps(
        sample s: StrokeSample,
        color: Color
    ) -> [StrokeStamp] {
        
        let position = s.position + s.stampOffset
        
        let strokeStamp = StrokeStamp(
            position: position,
            size: s.stampSize,
            rotation: s.stampRotation,
            alpha: s.stampAlpha,
            color: color)
        
        return [strokeStamp]
    }
    
}
