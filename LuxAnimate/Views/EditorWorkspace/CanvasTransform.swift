//
//  CanvasTransform.swift
//

import Foundation

struct CanvasTransform {
    
    var translation: Vector = .zero
    var rotation: Scalar = 0
    var scale: Scalar = 1
    
}

extension CanvasTransform {
    
    func applying(
        _ t: CanvasTransform
    ) -> CanvasTransform {
        
        var o = self
        o.translation += t.translation
        o.rotation += t.rotation
        o.scale *= t.scale
        return o
    }
    
}
