//
//  CanvasTransform.swift
//

import Foundation

struct CanvasTransform {
    
    var translation: Vector2 = .zero
    var rotation: Scalar = 0
    var scale: Scalar = 1
    
}

extension CanvasTransform {
    
    mutating func applyTranslation(
        _ d: Vector2
    ) {
        translation += d
    }
    
    mutating func applyRotation(_ d: Scalar, anchor: Vector2) {
        applyTranslation(-anchor)
        rotation += d
        translation = translation.rotated(by: d)
        applyTranslation(anchor)
    }
    
    mutating func applyScale(_ d: Scalar, anchor: Vector2) {
        applyTranslation(-anchor)
        scale *= d
        translation *= d
        applyTranslation(anchor)
    }
    
    func matrix() -> Matrix3 {
        let t1 = Matrix3(scale: Vector2(scale, scale))
        let t2 = Matrix3(rotation: rotation)
        let t3 = Matrix3(translation: translation)
        
        return t3 * t2 * t1
    }
    
}
