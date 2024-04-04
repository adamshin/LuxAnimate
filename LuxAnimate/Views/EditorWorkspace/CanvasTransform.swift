//
//  CanvasTransform.swift
//

import Foundation

private let rotationSnapThreshold: Scalar =
    5 * .radiansPerDegree

struct CanvasTransform {
    
    var translation: Vector2 = .zero
    var rotation: Scalar = 0
    var scale: Scalar = 1
    
}

extension CanvasTransform {
    
    mutating func applyTranslation(
        _ dTranslation: Vector2
    ) {
        translation += dTranslation
    }
    
    mutating func applyRotation(
        _ dRotation: Scalar,
        anchor: Vector2
    ) {
        applyTranslation(-anchor)
        
        rotation = wrap(rotation + dRotation, to: .twoPi)
        translation = translation.rotated(by: dRotation)
        
        applyTranslation(anchor)
    }
    
    mutating func applyScale(
        _ dScale: Scalar,
        min: Scalar,
        max: Scalar,
        anchor: Vector2
    ) {
        let newScale = clamp(
            scale * dScale,
            min: min,
            max: max)
        let scaleFactor = newScale / scale
        
        applyTranslation(-anchor)
        
        scale *= scaleFactor
        translation *= scaleFactor
        
        applyTranslation(anchor)
    }
    
    mutating func snapRotation() {
        let snapAngles: [Scalar] = (0...4)
            .map { Scalar($0) / 4 * .twoPi }
        
        for snapAngle in snapAngles {
            let distance = snapAngle - rotation
            if abs(distance) < rotationSnapThreshold {
                rotation = snapAngle
                break
            }
        }
    }
    
    func matrix() -> Matrix3 {
        let t1 = Matrix3(scale: Vector2(scale, scale))
        let t2 = Matrix3(rotation: rotation)
        let t3 = Matrix3(translation: translation)
        
        return t3 * t2 * t1
    }
    
}
