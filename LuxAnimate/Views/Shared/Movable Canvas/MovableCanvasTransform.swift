//
//  MovableCanvasTransform.swift
//

import Foundation
import Geometry

struct MovableCanvasTransform {
    
    var translation: Vector2 = .zero
    var rotation: Double = 0
    var scale: Double = 1
    
}

extension MovableCanvasTransform {
    
    mutating func applyTranslation(
        _ dTranslation: Vector2
    ) {
        translation += dTranslation
    }
    
    mutating func applyRotation(
        _ dRotation: Double,
        anchor: Vector2
    ) {
        applyTranslation(-anchor)
        
        rotation = wrap(rotation + dRotation, to: .twoPi)
        translation = translation.rotated(by: dRotation)
        
        applyTranslation(anchor)
    }
    
    mutating func applyScale(
        _ dScale: Double,
        minScale: Double,
        maxScale: Double,
        anchor: Vector2
    ) {
        let newScale = clamp(
            scale * dScale,
            min: minScale,
            max: maxScale)
        
        let scaleFactor = max(0, newScale / scale)
        
        applyTranslation(-anchor)
        
        scale *= scaleFactor
        translation *= scaleFactor
        
        applyTranslation(anchor)
    }
    
    mutating func snapTranslationToKeepRectContainingOrigin(
        x: Double, y: Double,
        width: Double, height: Double
    ) {
        let matrix = matrix()
        let matrixInverse = matrix.inverse()
        
        let targetPointInRectSpace = matrixInverse * Vector.zero
        
        let closestRectPointInRectSpace = Vector(
            x: clamp(targetPointInRectSpace.x, min: x, max: x + width),
            y: clamp(targetPointInRectSpace.y, min: y, max: y + height))
        
        let closestRectPointInViewSpace = matrix * closestRectPointInRectSpace
        
        applyTranslation(-closestRectPointInViewSpace)
    }
    
    mutating func snapRotation(threshold: Double) {
        let snapAngles: [Double] = (0...4)
            .map { Double($0) / 4 * .twoPi }
        
        for snapAngle in snapAngles {
            let distance = snapAngle - rotation
            if abs(distance) < threshold {
                applyRotation(distance, anchor: .zero)
                break
            }
        }
    }
    
    mutating func snapScale(
        minScale: Double,
        maxScale: Double
    ) {
        applyScale(1,
            minScale: minScale,
            maxScale: maxScale,
            anchor: .zero)
    }
    
    func matrix() -> Matrix3 {
        let t1 = Matrix3(scale: Vector2(scale, scale))
        let t2 = Matrix3(rotation: rotation)
        let t3 = Matrix3(translation: translation)
        
        return t3 * t2 * t1
    }
    
}
